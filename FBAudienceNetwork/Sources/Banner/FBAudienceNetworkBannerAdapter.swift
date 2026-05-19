//
//  FBAudienceNetworkBannerAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 6/17/24.
//
import UIKit

import APSSPSDK


final public class FBAudienceNetworkBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let facebookBannerView: FBAudienceNetworkMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fanPlacementId.rawValue] ?? ""
//        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        self.facebookBannerView = FBAudienceNetworkMediationBannerView(placementId: placementId,
                                                                       bannerType: bannerType,
                                                                       biddingData: "",
                                                                       rootviewcontroller: rootViewController)
        self.rootViewController = rootViewController
        facebookBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        facebookBannerView.load()
    }
    
    public func disconnectDelegate() {
        facebookBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        facebookBannerView.stop()
    }
}


extension FBAudienceNetworkBannerAdapter: APSSPBannerAdapterDelegate {
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



