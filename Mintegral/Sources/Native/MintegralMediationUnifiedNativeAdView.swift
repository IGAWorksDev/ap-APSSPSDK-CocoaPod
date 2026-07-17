//
//  MintegralMediationUnifiedNativeAdView.swift
//  MediationMintegral
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import MTGSDK
import MTGSDKBidding
import APSSPSDK


final class MintegralMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private let unitId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAdManager: MTGNativeAdManager?
    private var bidNativeAdManager: MTGBidNativeAdManager?
    private var mediaView: MTGMediaView?
    private var biddingData: String?
    
    
    init(placementId: String, unitId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, biddingData: String? = nil) {
        self.placementId = placementId
        self.unitId = unitId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("MintegralMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard !unitId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral unitId is empty")
            return
        }
        
        guard let rootViewController else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        APLogger.debug("Start Mintegral UnifiedNative load, placementId: \(placementId), UnitID: \(unitId), bidding: \(biddingData != nil)")
        
        if let biddingData, !biddingData.isEmpty {
            // Bidding: MTGBidNativeAdManager 사용
            bidNativeAdManager = MTGBidNativeAdManager(placementId: placementId,
                                                       unitID: unitId,
                                                       presenting: rootViewController)
            bidNativeAdManager?.delegate = self
            bidNativeAdManager?.load(withBidToken: biddingData)
        } else {
            // Waterfall: MTGNativeAdManager 사용
            var templates: [Any] = []
               if let template = MTGTemplate(type: .MTGAD_TEMPLATE_BIG_IMAGE, adsNum: 1) {
                   templates.append(template)
               }
            
            nativeAdManager = MTGNativeAdManager(placementId: placementId,
                                                 unitID: unitId,
                                                 supportedTemplates: templates,
                                                 autoCacheImage: false,
                                                 adCategory: .MTGAD_CATEGORY_ALL,
                                                 presenting: rootViewController)
            nativeAdManager?.delegate = self
            nativeAdManager?.loadAds()
        }
    }
    
    func stop() {
        nativeAdManager?.delegate = nil
        nativeAdManager = nil
        bidNativeAdManager?.delegate = nil
        bidNativeAdManager = nil
        mediaView = nil
    }
}

extension MintegralMediationUnifiedNativeAdView: MTGNativeAdManagerDelegate, MTGBidNativeAdManagerDelegate, MTGMediaViewDelegate {
    
    func nativeAdsLoaded(_ nativeAds: [Any]?, nativeManager: MTGNativeAdManager) {
        guard let campaign = nativeAds?.first as? MTGCampaign else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral campaign is nil")
            return
        }
        
        // 텍스트 바인딩
        viewBinder.titleLabel?.text = campaign.appName
        viewBinder.bodyLabel?.text = campaign.appDesc
        viewBinder.ctaButton?.setTitle(campaign.adCall, for: .normal)
        
        // 아이콘
        campaign.loadIconUrlAsync { [weak self] image in
            if let image { self?.viewBinder.iconImageView?.image = image }
        }
        
        // MediaView → mediaContainerView
        let mtgMediaView = MTGMediaView()
        self.mediaView = mtgMediaView
        print(self.mediaView?.unitId)
        mtgMediaView.delegate = self
        viewBinder.insertMediaView(mtgMediaView)
        mtgMediaView.setMediaSourceWith(campaign, unitId: unitId)
        print(self.mediaView?.unitId)
        // 옵셔널 뷰 숨김
        viewBinder.hideAllOptionalViews()
        
        // clickable views 수집 + registerView
        var clickableViews: [UIView] = []
        if let v = viewBinder.titleLabel { clickableViews.append(v) }
        if let v = viewBinder.bodyLabel { clickableViews.append(v) }
        if let v = viewBinder.ctaButton { clickableViews.append(v) }
        if let v = viewBinder.iconImageView { clickableViews.append(v) }
        clickableViews.append(mtgMediaView)
        
        if let container = viewBinder.containerView {
            if let bidLoader = bidNativeAdManager {
                bidLoader.registerView(forInteraction: container, withClickableViews: clickableViews, with: campaign)
            } else {
                nativeAdManager?.registerView(forInteraction: container, withClickableViews: clickableViews, with: campaign)
            }
        }
        
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAdsFailedToLoadWithError(_ error: any Error, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeClicked(message: "Mintegral UnifiedNative clicked")
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeImpression(message: "Mintegral UnifiedNative impression")
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, mediaView: MTGMediaView) {
        delegate?.unifiedNativeClicked(message: "Mintegral UnifiedNative mediaView clicked")
    }
}
