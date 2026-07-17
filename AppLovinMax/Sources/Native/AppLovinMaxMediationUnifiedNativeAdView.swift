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
        
        // MANativeAdView 생성 및 containerView에 overlay
        setupMANativeAdView()
        guard let maNativeAdView else {
            APLogger.error("AppLovinMax MANativeAdView setup failed")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "MANativeAdView setup failed")
            return
        }
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: placementId)
        nativeAdLoader?.nativeAdDelegate = self
        nativeAdLoader?.setExtraParameterForKey(disableAutoRetriesParam, value: "true")
        nativeAdLoader?.setExtraParameterForKey(priceParam, value: price)
        APLogger.debug("Start AppLovinMax UnifiedNative load, UnitID: \(placementId)")
        nativeAdLoader?.loadAd(into: maNativeAdView)
    }
    
    func stop() {
        if let nativeAd {
            nativeAdLoader?.destroy(nativeAd)
        }
        nativeAdLoader = nil
        nativeAd = nil
        maNativeAdView?.removeFromSuperview()
        maNativeAdView = nil
    }
}


// MARK: - MANativeAdView 설정 및 ViewBinder 바인딩
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
            bindToViewBinder(nativeAd: nativeAdData)
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
