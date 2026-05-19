//
//  VungleBannerAdapter.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/20/24.
//

import UIKit

import APSSPSDK


final public class VungleBannerAdapter: APSSPBannerAdapterInappBiddingProtocol {

    private let bannerView: VungleMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.vunglePlacementId.rawValue] ?? ""
        self.bannerView = VungleMediationBannerView(placementId: placementId, 
                                                       bannerType: bannerType,
                                                       rootviewcontroller: rootViewController)
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.vunglePlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.bannerView = VungleMediationBannerView(placementId: placementId,
                                                    bannerType: bannerType,
                                                    rootviewcontroller: rootViewController,
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


extension VungleBannerAdapter: APSSPBannerAdapterDelegate {
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



