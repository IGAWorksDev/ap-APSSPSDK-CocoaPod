//
//  UnityAdsBannerAdapter.swift
//  MediationUnityAds
//
//  Created by Odin on 2026/06/04.
//

import UIKit
import APSSPSDK


final public class UnityAdsBannerAdapter: APSSPBannerAdapterInappBiddingProtocol {

    private let bannerView: UnityAdsMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.unityPlacementId.rawValue] ?? ""
        let gameID = placementDic[APSSPPlacementKey.unityGameId.rawValue] ?? ""
        self.bannerView = UnityAdsMediationBannerView(gameID: gameID,
                                                       placementId: placementId,
                                                       bannerType: bannerType,
                                                       rootViewController: rootViewController)
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }
    public init(inappbiddingPlacementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.unityPlacementId.rawValue] ?? ""
        let gameID = inappbiddingPlacementDic[APSSPBiddingKey.unityGameId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.bannerView = UnityAdsMediationBannerView(gameID: gameID,
                                                      placementId: placementId,
                                                      bannerType: bannerType,
                                                      rootViewController: rootViewController,
                                                      biddingData: biddingData)
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        bannerView.load()
    }
    
    public func disconnectDelegate() {
        bannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        bannerView.stop()
    }
    
    public func getBiddingToken() -> String {
        return bannerView.getBiddingToken()
    }
}


extension UnityAdsBannerAdapter: APSSPBannerAdapterDelegate {
    public func bannerViewSuccess(bannerView: UIView) {
        delegate?.bannerViewSuccess(bannerView: bannerView)
    }
    
    public func bannerViewFailed(bannerView: UIView, error: APSSPNetworkError, errorMessage: String?) {
        delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: errorMessage)
    }
    
    public func bannerViewClicked(message: String) {
        delegate?.bannerViewClicked(message: message)
    }
    
    public func bannerViewImpression(message: String) {
        delegate?.bannerViewImpression(message: message)
    }
}
