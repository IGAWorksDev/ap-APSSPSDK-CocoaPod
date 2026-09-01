//
//  GAMMediationUnifiedNativeAdView.swift
//  MediationGAM
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import GoogleMobileAds
import APSSPSDK


/// GAM 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// GADAdLoader로 광고를 로드하고, ViewBinder에 데이터를 바인딩합니다.
final class GAMMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var adLoader: AdLoader?
    private var nativeAd: NativeAd?
    
    /// GADNativeAdView — 클릭 등록에 필수.
    /// - 기존 경로: containerView에 투명 overlay
    /// - 신규 경로: 매체 화면(contentView)을 감싸는 컨테이너
    private var gadNativeAdView: NativeAdView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?

    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("GAMMediationUnifiedNativeAdView deinit")
    }
    
    // MARK: - Public
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("GAM UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let multipleAdOptions = MultipleAdsAdLoaderOptions()
        adLoader = AdLoader(
            adUnitID: placementId,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: [multipleAdOptions]
        )
        adLoader?.delegate = self
        adLoader?.load(Request())
    }
    
    func stop() {
        nativeAd?.delegate = nil
        nativeAd = nil
        adLoader = nil

        // 신규(레시피) 경로에서 조립한 뷰만 정리한다. (기존 경로 동작은 그대로 유지)
        if contentView != nil {
            gadNativeAdView?.removeFromSuperview()
            gadNativeAdView = nil
        }
        contentView?.removeFromSuperview()
        contentView = nil
    }
}


// MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)
private extension GAMMediationUnifiedNativeAdView {
    
    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func bindToViewBinder() {
        guard let nativeAd else { return }
        
        // 1. GADNativeAdView 생성 및 containerView에 overlay
        setupGADNativeAdView()
        guard let gadNativeAdView else { return }
        
        // 2. 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.headline
        viewBinder.bodyLabel?.text = nativeAd.body
        
        if let ctaText = nativeAd.callToAction {
            viewBinder.ctaButton?.setTitle(ctaText, for: .normal)
        }
        
        // 3. 아이콘 이미지
        if let icon = nativeAd.icon?.image {
            viewBinder.iconImageView?.image = icon
        }
        
        // 4. 옵셔널 필드
        var visibleKeys = Set<String>()
        
        if let advertiser = nativeAd.advertiser {
            viewBinder.advertiserLabel?.text = advertiser
            visibleKeys.insert("advertiser")
        }
        if let store = nativeAd.store {
            viewBinder.storeLabel?.text = store
            visibleKeys.insert("store")
        }
        if let price = nativeAd.price {
            viewBinder.priceLabel?.text = price
            visibleKeys.insert("price")
        }
        if let starRating = nativeAd.starRating {
            if starRating.doubleValue >= 3.0 {
                visibleKeys.insert("starRating")
            }
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // 5. MediaView → mediaContainerView에 삽입
        if let _ = viewBinder.mediaContainerView {
            let mediaView = MediaView()
            mediaView.mediaContent = nativeAd.mediaContent
            viewBinder.insertMediaView(mediaView)
            gadNativeAdView.mediaView = mediaView
        }
        
        // 6. GADNativeAdView에 각 view 등록 (click tracking용)
        gadNativeAdView.headlineView = viewBinder.titleLabel
        gadNativeAdView.bodyView = viewBinder.bodyLabel
        gadNativeAdView.callToActionView = viewBinder.ctaButton
        gadNativeAdView.iconView = viewBinder.iconImageView
        gadNativeAdView.storeView = viewBinder.storeLabel
        gadNativeAdView.priceView = viewBinder.priceLabel
        gadNativeAdView.advertiserView = viewBinder.advertiserLabel
        gadNativeAdView.starRatingView = viewBinder.starRatingView
        
        // CTA 버튼 직접 터치 비활성화 (GADNativeAdView가 처리)
        viewBinder.ctaButton?.isUserInteractionEnabled = false
        
        // 7. nativeAd 연결 (필수 — click/impression tracking 동작)
        gadNativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
    }
    
    func setupGADNativeAdView() {
        guard let container = viewBinder.containerView else { return }
        
        let adView = NativeAdView()
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.backgroundColor = .clear
        adView.isUserInteractionEnabled = true
        container.insertSubview(adView, at: 0)
        
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        self.gadNativeAdView = adView
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension GAMMediationUnifiedNativeAdView {

    /// 매체가 구성한 화면(`APSSPUnifiedNativeAdView`)을 `NativeAdView` **안에** 넣어 계층을 바로잡는다.
    /// 계층이 정상이므로 투명 오버레이 / CTA 터치 비활성화 같은 우회가 필요 없다.
    func handleNativeAdWithContentView(_ nativeAd: NativeAd) {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "GAM placeholder is nil")
            return
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "GAM contentView 생성 실패")
            return
        }
        self.contentView = content

        // 1. 업체 컨테이너 생성 + 매체 화면을 그 "안에" 삽입
        let adView = NativeAdView()
        self.gadNativeAdView = adView
        APSSPUnifiedNativeAssembler.wrap(content, in: adView)

        // 2. 빈 슬롯 채우기 — 업체 전용 뷰는 어댑터가 생성
        //    NativeAdView.mediaView는 weak이므로 계층에 넣은 뒤 대입해야 한다.
        let mediaView = MediaView()
        mediaView.mediaContent = nativeAd.mediaContent
        if APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
            adView.mediaView = mediaView
        } else {
            APLogger.error("GAM UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        // AdChoices — GAD는 전용 AdChoicesView를 슬롯에 채워야 한다.
        // 슬롯이 없으면 대입하지 않고 SDK 기본 위치(모서리)에 맡긴다.
        var hasAdChoiceSlot = false
        if let adChoiceSlot = content.adChoiceContainerView {
            let adChoicesView = AdChoicesView()
            if APSSPUnifiedNativeAssembler.fillSlot(adChoiceSlot, with: adChoicesView) {
                adView.adChoicesView = adChoicesView
                hasAdChoiceSlot = true
            }
        }

        // 3. setter 등록 — 이제 모두 adView의 자손
        adView.headlineView = content.titleLabel
        adView.bodyView = content.bodyLabel
        adView.callToActionView = content.ctaButton
        adView.iconView = content.iconImageView
        adView.storeView = content.storeLabel
        adView.priceView = content.priceLabel
        adView.advertiserView = content.advertiserLabel
        adView.starRatingView = content.starRatingView

        // 4. 데이터 바인딩
        content.titleLabel?.text = nativeAd.headline
        content.bodyLabel?.text = nativeAd.body
        content.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)
        content.iconImageView?.image = nativeAd.icon?.image

        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()
        if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
            content.advertiserLabel?.text = advertiser
            visibleKeys.insert(.advertiser)
        }
        if let store = nativeAd.store, !store.isEmpty {
            content.storeLabel?.text = store
            visibleKeys.insert(.store)
        }
        if let price = nativeAd.price, !price.isEmpty {
            content.priceLabel?.text = price
            visibleKeys.insert(.price)
        }
        // 별점은 SDK가 그려주지 않는다. 매체가 배치한 뷰가 있고 값이 있을 때만 노출하고,
        // 실제 렌더(별 이미지/숫자)는 매체 뷰에 맡긴다.
        // 별점은 숫자로만 오므로 SDK가 화면에 반영한다. (매체는 starRating 값 또는 applyStarRating 오버라이드로 커스텀 가능)
        content.updateStarRating(nativeAd.starRating)
        if hasAdChoiceSlot {
            visibleKeys.insert(.adChoice)
        }
        content.hideOptionalViews(except: visibleKeys)

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        content.hideEmptyViews()

        // 5. nativeAd 연결 — 반드시 마지막 (미디어 렌더 + 클릭/임프레션 트래킹 시작)
        adView.nativeAd = nativeAd
        nativeAd.delegate = self

        // 6. 플레이스홀더에 부착
        APSSPUnifiedNativeAssembler.attach(adView, to: placeholder)
    }
}


// MARK: - GAD Delegates
extension GAMMediationUnifiedNativeAdView: NativeAdLoaderDelegate, NativeAdDelegate {

    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        if viewBinder.isContentViewMode {
            APLogger.debug("GAM UnifiedNative → 매체 XIB (신규 구조)")
            handleNativeAdWithContentView(nativeAd)
        } else {
            bindToViewBinder()
        }
    }
    
    public func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        APLogger.error("GAM UnifiedNative Error: \(error.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        delegate?.unifiedNativeClicked(message: "GAM UnifiedNative clicked")
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        delegate?.unifiedNativeImpression(message: "GAM UnifiedNative impression")
    }
}
