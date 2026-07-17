//
//  AdMobMediationUnifiedNativeAdView.swift
//  MediationAdMob
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import GoogleMobileAds
import APSSPSDK


/// AdMob 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// GADAdLoader로 광고를 로드하고, ViewBinder에 데이터를 바인딩합니다.
final class AdMobMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var adLoader: AdLoader?
    private var nativeAd: NativeAd?
    
    /// GADNativeAdView — 클릭 등록에 필수. containerView에 투명 overlay.
    private var gadNativeAdView: NativeAdView?
    
    
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
        APLogger.debug("AdMobMediationUnifiedNativeAdView deinit")
    }
    
    // MARK: - Public
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AdMob UnifiedNative placementId is empty")
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
    }
}


// MARK: - ViewBinder 바인딩
private extension AdMobMediationUnifiedNativeAdView {
    
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
        
        // GADNativeAdView를 containerView와 동일한 부모에, containerView 위에 배치
        // 그리고 containerView의 모든 subview를 GADNativeAdView 안으로 이동
        let adView = NativeAdView()
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.backgroundColor = .clear
        adView.isUserInteractionEnabled = true
        
        // containerView의 부모에 GADNativeAdView 삽입 (containerView 자리에)
        if let parent = container.superview {
            parent.insertSubview(adView, aboveSubview: container)
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: container.topAnchor),
                adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else {
            // 부모가 없으면 containerView 안에 배치
            container.addSubview(adView)
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: container.topAnchor),
                adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        
        self.gadNativeAdView = adView
    }
}


// MARK: - GAD Delegates
extension AdMobMediationUnifiedNativeAdView: NativeAdLoaderDelegate, NativeAdDelegate {
    
    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        bindToViewBinder()
    }
    
    public func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        APLogger.error("AdMob UnifiedNative Error: \(error.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        delegate?.unifiedNativeClicked(message: "AdMob UnifiedNative clicked")
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        delegate?.unifiedNativeImpression(message: "AdMob UnifiedNative impression")
    }
}
