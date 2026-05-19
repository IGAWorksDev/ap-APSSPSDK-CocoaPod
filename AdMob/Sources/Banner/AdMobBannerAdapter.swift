//
//  AdmobBannerAdapter.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/05/16.
//

import UIKit

import APSSPSDK


final public class AdMobBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let admobBannerView: AdMobMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.admobBannerView = AdMobMediationBannerView(placementId: placementId, width: bannerType.width, height: bannerType.height, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        admobBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        admobBannerView.load()
    }
    
    public func disconnectDelegate() {
        admobBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        admobBannerView.stop()
    }
}


extension AdMobBannerAdapter: APSSPBannerAdapterDelegate {
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



