//
//  AppLovinMaxMediationUnifiedNativeAdView.swift
//  MediationAppLovinMax
//
//  Created by Kiro on 2026/07/06.
//

import UIKit
import AppLovinSDK
import APSSPSDK


/// AppLovin MAX 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// MANativeAdLoader로 광고를 로드하고, ViewBinder에 데이터를 바인딩합니다.
final class AppLovinMaxMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private let price: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAdLoader: MANativeAdLoader?
    private var nativeAd: MAAd?
    
    /// MANativeAdView — 클릭 등록에 필수. containerView에 투명 overlay.
    private var maNativeAdView: MANativeAdView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?

    private let priceParam = "jC7Fp"
    private let disableAutoRetriesParam = "disable_auto_retries"
    
    
    init(placementId: String, price: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.price = price
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("AppLovinMaxMediationUnifiedNativeAdView deinit")
    }
    
    // MARK: - Public
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AppLovinMax UnifiedNative Ad Unit ID is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Ad Unit ID is empty")
            return
        }
        
        guard rootViewController != nil else {
            APLogger.error("AppLovinMax UnifiedNative rootViewController is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }

        if viewBinder.isContentViewMode {
            APLogger.debug("AppLovinMax UnifiedNative → 매체 XIB (신규 구조)")
            loadWithContentView()
        } else {
            loadWithViewBinder()
        }
    }

    func stop() {
        if let nativeAd {
            nativeAdLoader?.destroy(nativeAd)
        }
        nativeAdLoader = nil
        nativeAd = nil
        maNativeAdView?.removeFromSuperview()
        maNativeAdView = nil
        contentView = nil
    }
}


// MARK: - 로드 / 바인딩
private extension AppLovinMaxMediationUnifiedNativeAdView {
    
    /// Tag 상수
    enum ViewTag {
        static let title: Int = 10001
        static let body: Int = 10002
        static let cta: Int = 10003
        static let icon: Int = 10004
        static let media: Int = 10005
        static let advertiser: Int = 10006
        static let options: Int = 10007
        static let starRating: Int = 10008
    }

    // MARK: - [NEW] ContentView 방식 — 매체 XIB를 MANativeAdView 안에 넣는다

    /// `MANativeAdViewBinder`는 **`MANativeAdView`의 서브트리에서만** tag로 뷰를 찾는다.
    /// 따라서 매체 화면을 컨테이너 안으로 재부모화(wrap)하는 단계가 반드시 필요하다.
    func loadWithContentView() {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            APLogger.error("AppLovinMax UnifiedNative placeholder is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AppLovinMax placeholder is nil")
            return
        }

        guard let content = viewBinder.makeContentView() else {
            APLogger.error("AppLovinMax UnifiedNative contentView 생성 실패")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AppLovinMax contentView 생성 실패")
            return
        }
        self.contentView = content

        // 1. content의 각 뷰에 고유 tag 부여
        content.titleLabel?.tag = ViewTag.title
        content.bodyLabel?.tag = ViewTag.body
        content.ctaButton?.tag = ViewTag.cta
        content.iconImageView?.tag = ViewTag.icon
        content.mediaContainerView?.tag = ViewTag.media
        content.advertiserLabel?.tag = ViewTag.advertiser
        content.adChoiceContainerView?.tag = ViewTag.options
        content.starRatingView?.tag = ViewTag.starRating

        // 2. binder에 위에서 부여한 tag를 지정
        let binder = MANativeAdViewBinder { builder in
            builder.titleLabelTag = ViewTag.title
            builder.bodyLabelTag = ViewTag.body
            builder.callToActionButtonTag = ViewTag.cta
            builder.iconImageViewTag = ViewTag.icon
            builder.mediaContentViewTag = ViewTag.media
            builder.advertiserLabelTag = ViewTag.advertiser
            builder.optionsContentViewTag = ViewTag.options
            builder.starRatingContentViewTag = ViewTag.starRating
        }

        // 3. 업체 컨테이너 생성 + 매체 화면을 그 "안에" 삽입 (재부모화 — 필수)
        let adView = MANativeAdView()
        adView.backgroundColor = .clear
        adView.isUserInteractionEnabled = true
        self.maNativeAdView = adView
        APSSPUnifiedNativeAssembler.wrap(content, in: adView)

        // 4. tag 탐색은 adView 서브트리 기준이므로 wrap 이후에 호출해야 한다
        adView.bindViews(with: binder)

        // 5. 플레이스홀더에 부착
        APSSPUnifiedNativeAssembler.attach(adView, to: placeholder)

        // 6. 로드
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: placementId)
        nativeAdLoader?.nativeAdDelegate = self
        // impression은 revenue 콜백으로만 올라오므로 revenueDelegate 설정이 필수
        nativeAdLoader?.revenueDelegate = self
        nativeAdLoader?.setExtraParameterForKey(disableAutoRetriesParam, value: "true")
        nativeAdLoader?.setExtraParameterForKey(priceParam, value: price)
        APLogger.debug("Start AppLovinMax UnifiedNative load, UnitID: \(placementId)")
        nativeAdLoader?.loadAd(into: adView)
    }

    /// 매체 화면에 데이터 바인딩.
    /// MAX SDK가 binder tag로 찾은 뷰를 직접 렌더하지만, 옵셔널 뷰 표시/숨김은 어댑터가 결정한다.
    func bindToContentView(nativeAd: MANativeAd) {
        guard let content = contentView else { return }

        // 1. 텍스트 바인딩
        content.titleLabel?.text = nativeAd.title
        content.bodyLabel?.text = nativeAd.body

        if let ctaText = nativeAd.callToAction {
            content.ctaButton?.setTitle(ctaText, for: .normal)
        }

        // 2. 아이콘 이미지 — URL 케이스는 비동기라 완료 콜백에서 노출 여부를 결정한다.
        if let iconImage = nativeAd.icon?.image {
            content.iconImageView?.image = iconImage
        } else if let iconURL = nativeAd.icon?.url {
            loadImage(from: iconURL) { [weak self] image in
                self?.contentView?.iconImageView?.image = image
                self?.contentView?.iconImageView?.isHidden = (image == nil)
            }
        } else {
            // 아이콘 에셋 자체가 없다 — XIB placeholder(회색 배경)가 남지 않도록 즉시 숨긴다.
            content.iconImageView?.isHidden = true
        }

        // 3. MediaView — SDK가 mediaContentView(tag)에 자동 삽입한다.
        //    삽입되지 않은 경우에만 어댑터가 슬롯을 채운다.
        if let mediaView = nativeAd.mediaView, mediaView.superview == nil {
            APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView)
        }

        // 4. 옵셔널 필드
        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()

        if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
            content.advertiserLabel?.text = advertiser
            visibleKeys.insert(.advertiser)
        }
        // 별점은 숫자로만 오므로 SDK가 화면에 반영한다.
        content.updateStarRating(nativeAd.starRating)
        if content.adChoiceContainerView != nil {
            visibleKeys.insert(.adChoice)
        }

        content.hideOptionalViews(except: visibleKeys)

        // 광고에 없는 에셋(CTA 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // 아이콘은 URL 비동기 로드라 이 시점에 nil로 오판되므로 판정에서 제외하고 위 2번에서 처리한다.
        // hidesEmptySlots: false — MAX는 options/media 뷰를 렌더 단계에서 슬롯에 삽입하므로,
        // 여기서 "자식 없음"으로 판정해 숨기면 AdChoices/미디어가 표시되지 않을 수 있다.
        content.hideEmptyViews(hidesIconWhenEmpty: false, hidesEmptySlots: false)

        // 신규 경로에서는 ctaButton의 터치를 비활성화하지 않는다.
        // (MANativeAdView가 content의 부모이므로 계층이 정상이고, 클릭은 SDK가 처리한다)
    }

    // MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func loadWithViewBinder() {
        // MANativeAdView 생성 및 containerView에 overlay
        setupMANativeAdView()
        guard let maNativeAdView else {
            APLogger.error("AppLovinMax MANativeAdView setup failed")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "MANativeAdView setup failed")
            return
        }

        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: placementId)
        nativeAdLoader?.nativeAdDelegate = self
        // impression은 revenue 콜백으로만 올라오므로 revenueDelegate 설정이 필수
        nativeAdLoader?.revenueDelegate = self
        nativeAdLoader?.setExtraParameterForKey(disableAutoRetriesParam, value: "true")
        nativeAdLoader?.setExtraParameterForKey(priceParam, value: price)
        APLogger.debug("Start AppLovinMax UnifiedNative load, UnitID: \(placementId)")
        nativeAdLoader?.loadAd(into: maNativeAdView)
    }

    func setupMANativeAdView() {
        guard let container = viewBinder.containerView else { return }
        
        // 1. Tag 먼저 설정 (MANativeAdViewBinder가 tag로 뷰를 찾음)
        setViewTags()
        
        // 2. MANativeAdView 생성
        let adView = MANativeAdView()
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.backgroundColor = UIColor.clear
        adView.isUserInteractionEnabled = true
        
        // 3. ViewBinder의 뷰들을 MANativeAdView에 subview로 추가
        // (MANativeAdView가 서브뷰에서 tag로 뷰를 찾아 클릭 영역 등록)
//        addSubviewsToNativeAdView(adView)
        
        // 4. MANativeAdViewBinder 생성 및 바인딩
        let binder = MANativeAdViewBinder { builder in
            builder.titleLabelTag = ViewTag.title
            builder.bodyLabelTag = ViewTag.body
            builder.callToActionButtonTag = ViewTag.cta
            builder.iconImageViewTag = ViewTag.icon
            builder.mediaContentViewTag = ViewTag.media
            builder.advertiserLabelTag = ViewTag.advertiser
            builder.optionsContentViewTag = ViewTag.options
        }
        adView.bindViews(with: binder)
        
        // 5. container에 MANativeAdView overlay
        container.insertSubview(adView, at: 0)
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        self.maNativeAdView = adView
    }
    
    func setViewTags() {
        // MANativeAdViewBinder가 tag를 통해 뷰를 찾으므로 고유 tag 설정
        viewBinder.titleLabel?.tag = ViewTag.title
        viewBinder.bodyLabel?.tag = ViewTag.body
        viewBinder.ctaButton?.tag = ViewTag.cta
        viewBinder.iconImageView?.tag = ViewTag.icon
        viewBinder.mediaContainerView?.tag = ViewTag.media
        viewBinder.advertiserLabel?.tag = ViewTag.advertiser
        viewBinder.adChoiceContainerView?.tag = ViewTag.options
    }
    
    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func bindToViewBinder(nativeAd: MANativeAd) {
        // 1. 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.title
        viewBinder.bodyLabel?.text = nativeAd.body
        
        if let ctaText = nativeAd.callToAction {
            viewBinder.ctaButton?.setTitle(ctaText, for: .normal)
        }
        
        // 2. 아이콘 이미지
        if let iconImage = nativeAd.icon?.image {
            viewBinder.iconImageView?.image = iconImage
        } else if let iconURL = nativeAd.icon?.url {
            loadImage(from: iconURL) { [weak self] image in
                self?.viewBinder.iconImageView?.image = image
            }
        }
        
        // 3. 옵셔널 필드
        var visibleKeys = Set<String>()
        
        if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
            viewBinder.advertiserLabel?.text = advertiser
            visibleKeys.insert("advertiser")
        }
        
        if let starRating = nativeAd.starRating, starRating.doubleValue >= 3.0 {
            visibleKeys.insert("starRating")
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // 4. MediaView → mediaContainerView에 삽입
        if let mediaView = nativeAd.mediaView {
            viewBinder.insertMediaView(mediaView)
        }
        
        // CTA 버튼 직접 터치 비활성화 (MANativeAdView가 처리)
        viewBinder.ctaButton?.isUserInteractionEnabled = false
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(image) }
        }
    }
}


// MARK: - MANativeAdDelegate
extension AppLovinMaxMediationUnifiedNativeAdView: MANativeAdDelegate {
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        // 기존 광고가 있으면 정리
        if let currentNativeAd = nativeAd {
            nativeAdLoader?.destroy(currentNativeAd)
        }
        
        nativeAd = ad
        
        // nativeAd의 실제 native ad 데이터 바인딩
        if let nativeAdData = ad.nativeAd {
            if viewBinder.isContentViewMode {
                bindToContentView(nativeAd: nativeAdData)
            } else {
                bindToViewBinder(nativeAd: nativeAdData)
            }
        }
        
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovinMax UnifiedNative Error: \(error.description)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        delegate?.unifiedNativeClicked(message: "AppLovinMax UnifiedNative clicked")
    }
    
    func didExpireNativeAd(_ ad: MAAd) {
        APLogger.debug("AppLovinMax UnifiedNative ad expired")
    }
}


// MARK: - MAAdRevenueDelegate (Optional)
extension AppLovinMaxMediationUnifiedNativeAdView: MAAdRevenueDelegate {
    func didPayRevenue(for ad: MAAd) {
        delegate?.unifiedNativeImpression(message: "AppLovinMax UnifiedNative impression (revenue)")
    }
}
