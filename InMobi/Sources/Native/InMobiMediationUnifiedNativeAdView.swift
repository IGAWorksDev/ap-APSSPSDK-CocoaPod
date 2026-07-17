//
//  InMobiMediationUnifiedNativeAdView.swift
//  MediationInMobi
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import InMobiSDK
import APSSPSDK


final class InMobiMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAd: IMNative?
    
    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("InMobiMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard let pid = Int64(placementId), pid > 0 else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "InMobi placementId is invalid")
            return
        }
        
        nativeAd = IMNative(placementId: pid, delegate: self)
        nativeAd?.load()
    }
    
    func stop() {
        nativeAd?.delegate = nil
        nativeAd = nil
    }
    
    private func bindToViewBinder() {
        guard let nativeAd else { return }
        
        viewBinder.titleLabel?.text = nativeAd.adTitle
        viewBinder.bodyLabel?.text = nativeAd.adDescription
        viewBinder.ctaButton?.setTitle(nativeAd.adCtaText, for: .normal)
        
        // Icon
        if let iconImage = nativeAd.adIcon?.imageview?.image {
            viewBinder.iconImageView?.image = iconImage
        }
        
        // MediaView (primaryView) → mediaContainerView에 삽입
        if let mediaView = nativeAd.getMediaView() {
            viewBinder.insertMediaView(mediaView)
        }
        
        // 옵셔널 필드
        var visibleKeys = Set<String>()
        if let advertiser = nativeAd.advertiserName, !advertiser.isEmpty {
            viewBinder.advertiserLabel?.text = advertiser
            visibleKeys.insert("advertiser")
        }
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // Tracking 등록
        registerTracking()
    }
    
    private func registerTracking() {
        guard let nativeAd, let container = viewBinder.containerView else { return }
        
        let builder = IMNativeViewData.Builder(adParentView: container)
        if let title = viewBinder.titleLabel { builder.setTitleView(title) }
        if let desc = viewBinder.bodyLabel { builder.setDescriptionView(desc) }
        if let cta = viewBinder.ctaButton { builder.setCTAView(cta) }
        if let icon = viewBinder.iconImageView { builder.setIconView(icon) }
        if let advertiser = viewBinder.advertiserLabel { builder.setAdvertiserView(advertiser) }
        nativeAd.registerViewForTracking(builder.build())
    }
}

extension InMobiMediationUnifiedNativeAdView: IMNativeDelegate {
    func nativeDidFinishLoading(_ native: IMNative) {
        bindToViewBinder()
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func native(_ native: IMNative, didFailToLoadWithError error: IMRequestStatus) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdImpressed(_ native: IMNative) {
        delegate?.unifiedNativeImpression(message: "InMobi UnifiedNative impression")
    }
    
    func native(_ native: IMNative, didInteractWithParams params: [String: Any]?) {
        delegate?.unifiedNativeClicked(message: "InMobi UnifiedNative clicked")
    }
}
