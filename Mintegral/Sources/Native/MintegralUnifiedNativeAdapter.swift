//
//  MintegralUnifiedNativeAdapter.swift
//  MediationMintegral
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import MTGSDK
import MTGSDKBidding
import APSSPSDK


final public class MintegralUnifiedNativeAdapter: APSSPUnifiedNativeAdapterInAppBiddingProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var mediationView: MintegralMediationUnifiedNativeAdView
    
    // MARK: - Waterfall 초기화
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.mintegralPlacementId.rawValue] ?? ""
        let unitId = placementDic[APSSPPlacementKey.mintegralUnitId.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = MintegralMediationUnifiedNativeAdView(
            placementId: placementId,
            unitId: unitId,
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
        let placementId = inappBiddingPlacementDic[APSSPBiddingKey.mintegralPlacementId.rawValue] ?? ""
        let unitId = inappBiddingPlacementDic[APSSPPlacementKey.mintegralUnitId.rawValue] ?? ""
        let biddingData = inappBiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = MintegralMediationUnifiedNativeAdView(
            placementId: placementId,
            unitId: unitId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config,
            biddingData: biddingData
        )
    }
    
    // MARK: - Bidding Token
    
    public func getBiddingToken() -> String {
        return MTGBiddingSDK.buyerUID() ?? ""
    }
    
    // MARK: - Protocol Methods
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        mediationView.delegate = self
        mediationView.load()
    }
    
    public func disconnectDelegate() { mediationView.delegate = nil; delegate = nil }
    public func stop() { mediationView.stop() }
}

extension MintegralUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
    public func unifiedNativeLoadSuccess() { delegate?.unifiedNativeLoadSuccess() }
    public func unifiedNativeLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.unifiedNativeLoadFail(error: error, errorMessage: errorMessage) }
    public func unifiedNativeClicked(message: String) { delegate?.unifiedNativeClicked(message: message) }
    public func unifiedNativeImpression(message: String) { delegate?.unifiedNativeImpression(message: message) }
}
