//
//  AppLovinBannerAdapter.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK


final public class AppLovinBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let applovinBannerView: AppLovinMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appLovinZoneId.rawValue] ?? ""
        self.applovinBannerView = AppLovinMediationBannerView(placementId: placementId, bannerType: bannerType, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        applovinBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        applovinBannerView.load()
    }
    
    public func disconnectDelegate() {
        applovinBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        applovinBannerView.stop()
    }
}


extension AppLovinBannerAdapter: APSSPBannerAdapterDelegate {
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



