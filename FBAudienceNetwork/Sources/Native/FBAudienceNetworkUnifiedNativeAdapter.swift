//
//  FBAudienceNetworkUnifiedNativeAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import FBAudienceNetwork
import APSSPSDK


/// FAN(Facebook) 통합형 네이티브 광고 Adapter.
/// InApp Bidding 지원을 위해 APSSPUnifiedNativeAdapterInAppBiddingProtocol을 conform합니다.
final public class FBAudienceNetworkUnifiedNativeAdapter: APSSPUnifiedNativeAdapterInAppBiddingProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var mediationView: FBAudienceNetworkMediationUnifiedNativeAdView
    
    
    // MARK: - Waterfall 초기화
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        let biddingData = placementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = FBAudienceNetworkMediationUnifiedNativeAdView(
            placementId: placementId,
            biddingData: biddingData,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    // MARK: - InApp Bidding 초기화
    
    public required init(inappBiddingPlacementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = inappBiddingPlacementDic[APSSPBiddingKey.facebookPlacementId.rawValue] ?? ""
        let biddingData = inappBiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = FBAudienceNetworkMediationUnifiedNativeAdView(
            placementId: placementId,
            biddingData: biddingData,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    // MARK: - Bidding Token
    
    public func getBiddingToken() -> String {
        return FBAdSettings.bidderToken
    }
    
    // MARK: - Protocol Methods
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        mediationView.delegate = self
        mediationView.load()
    }
    
    public func disconnectDelegate() {
        mediationView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        mediationView.stop()
    }
}

extension FBAudienceNetworkUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
    public func unifiedNativeLoadSuccess() { delegate?.unifiedNativeLoadSuccess() }
    public func unifiedNativeLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.unifiedNativeLoadFail(error: error, errorMessage: errorMessage) }
    public func unifiedNativeClicked(message: String) { delegate?.unifiedNativeClicked(message: message) }
    public func unifiedNativeImpression(message: String) { delegate?.unifiedNativeImpression(message: message) }
}
