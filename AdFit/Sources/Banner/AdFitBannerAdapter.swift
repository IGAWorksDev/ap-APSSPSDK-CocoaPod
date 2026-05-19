//
//  AdFitBannerAdapter.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/10/24.
//

import UIKit

import APSSPSDK


final public class AdFitBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let namBannerView: AdFitMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.clientId.rawValue] ?? ""
        self.namBannerView = AdFitMediationBannerView(placementId: placementId, bannerType: bannerType, rootviewcontroller: rootViewController)
        self.rootViewController = rootViewController
        namBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        namBannerView.load()
    }
    
    public func disconnectDelegate() {
        namBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        namBannerView.stop()
    }
}


extension AdFitBannerAdapter: APSSPBannerAdapterDelegate {
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



