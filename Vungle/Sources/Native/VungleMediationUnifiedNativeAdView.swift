//
//  VungleMediationUnifiedNativeAdView.swift
//  MediationVungle
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK
import VungleAdsSDK


/// Vungle 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// VungleNative로 광고를 로드하고, ViewBinder에 데이터를 바인딩합니다.
final class VungleMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    private var biddingData: String?
    
    private var nativeAd: VungleNative?
    
    /// VungleMediaView — mediaContainerView에 삽입.
    private var vungleMediaView: MediaView?
    
    
    init(placementId: String,
         rootViewController: UIViewController?,
         viewBinder: APSSPMediationViewBinder,
         config: APSSPNativeAdConfig?,
         biddingData: String?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("VungleMediationUnifiedNativeAdView deinit")
    }
    
    
    // MARK: - Public
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Vungle UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard rootViewController != nil else {
            APLogger.error("Vungle UnifiedNative rootViewController is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        nativeAd = VungleNative(placementId: placementId)
        nativeAd?.delegate = self
        
        APLogger.debug("Start Vungle UnifiedNative load, PlacementID: \(placementId)")
        
        if let biddingData, !biddingData.isEmpty {
            nativeAd?.load(biddingData)
        } else {
            nativeAd?.load()
        }
    }
    
    func stop() {
        if nativeAd != nil, viewBinder.containerView?.window != nil {
            nativeAd?.unregisterView()
        }
        vungleMediaView?.delegate = nil
        vungleMediaView = nil
        nativeAd?.delegate = nil
        nativeAd = nil
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


// MARK: - ViewBinder 바인딩
private extension VungleMediationUnifiedNativeAdView {
    
    func bindToViewBinder() {
        guard let nativeAd else { return }
        
        // 1. 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.title
        viewBinder.bodyLabel?.text = nativeAd.bodyText
        
        let ctaText = nativeAd.callToAction
        if !ctaText.isEmpty {
            viewBinder.ctaButton?.setTitle(ctaText, for: .normal)
        }
        
        // 2. 옵셔널 필드 바인딩
        var visibleKeys = Set<String>()
        
        let sponsoredText = nativeAd.sponsoredText
        if !sponsoredText.isEmpty {
            viewBinder.sponsoredLabel?.text = sponsoredText
            visibleKeys.insert("sponsored")
        }
        
        if nativeAd.adStarRating > 0 {
            visibleKeys.insert("starRating")
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // 3. MediaView → mediaContainerView에 삽입
        if viewBinder.mediaContainerView != nil {
            let mediaView = MediaView()
            mediaView.delegate = self
            viewBinder.insertMediaView(mediaView)
            self.vungleMediaView = mediaView
        }
        
        // 4. AdOptions 위치 설정 (Privacy 아이콘)
        nativeAd.adOptionsPosition = .topRight
        
        // 5. registerViewForInteraction 호출 (클릭 영역 등록)
        registerClickableViews()
    }
    
    func registerClickableViews() {
        guard let nativeAd,
              let containerView = viewBinder.containerView,
              let rootVC = rootViewController else {
            APLogger.error("Vungle UnifiedNative: cannot register - missing containerView or rootViewController")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Missing containerView or rootViewController")
            return
        }
        
        // 클릭 가능한 뷰 목록 구성
        var clickableViews: [UIView] = [containerView]
        
        if let ctaButton = viewBinder.ctaButton {
            clickableViews.append(ctaButton)
        }
        if let iconImageView = viewBinder.iconImageView {
            clickableViews.append(iconImageView)
        }
        
        // Vungle registerViewForInteraction 호출
        if let mediaView = vungleMediaView, let iconImageView = viewBinder.iconImageView {
            nativeAd.registerViewForInteraction(
                view: containerView,
                mediaView: mediaView,
                iconImageView: iconImageView,
                viewController: rootVC,
                clickableViews: clickableViews
            )
        } else if let mediaView = vungleMediaView {
            // iconImageView가 없는 경우
            nativeAd.registerViewForInteraction(
                view: containerView,
                mediaView: mediaView,
                iconImageView: nil,
                viewController: rootVC,
                clickableViews: clickableViews
            )
        } else {
            APLogger.error("Vungle UnifiedNative: mediaView is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "MediaView is nil")
            return
        }
    }
}


// MARK: - VungleNativeDelegate
extension VungleMediationUnifiedNativeAdView: VungleNativeDelegate {
    
    func nativeAdDidLoad(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did load")
        bindToViewBinder()
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAdDidFailToLoad(_ native: VungleNative, withError: NSError) {
        APLogger.error("Vungle UnifiedNative load failed: \(withError.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func nativeAdDidTrackImpression(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did track impression")
        delegate?.unifiedNativeImpression(message: "Vungle UnifiedNative impression")
    }
    
    func nativeAdDidClick(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did click")
        delegate?.unifiedNativeClicked(message: "Vungle UnifiedNative clicked")
    }
}


// MARK: - MediaViewDelegate
extension VungleMediationUnifiedNativeAdView: MediaViewDelegate {
    
    func mediaViewVideoDidPlay(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did play")
    }
    
    func mediaViewVideoDidPause(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did pause")
    }
    
    func mediaViewVideoDidEnd(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did end")
    }
    
    func mediaViewVideoDidMute(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did mute")
    }
    
    func mediaViewVideoDidUnmute(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did unmute")
    }
}
