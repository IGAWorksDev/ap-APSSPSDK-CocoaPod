//
//  AppLovinInterstitialVideoAdapter.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK


final public class AppLovinInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {
   
    private var applovinMediationInterstitialVideoAd: AppLovinMediationInterstitialVideoAd?
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appLovinZoneId.rawValue] ?? ""
        applovinMediationInterstitialVideoAd = AppLovinMediationInterstitialVideoAd(placementId: placementId)
        self.applovinMediationInterstitialVideoAd?.delegate = self
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        applovinMediationInterstitialVideoAd?.present(from: from) { completion() }
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        self.applovinMediationInterstitialVideoAd?.load()
    }

    public func disconnectDelegate() {
        applovinMediationInterstitialVideoAd?.delegate = nil
        delegate = nil
    }
}


extension AppLovinInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    
    public func interstitialVideoLoadSuccess() {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func interstitialVideoShowSuccess(message: String) {
        delegate?.interstitialVideoShowSuccess(message: message)
    }
    
    public func interstitialVideoShowFail(message: String) {
        delegate?.interstitialVideoShowFail(message: message)
    }
    
    public func interstitialVideoClicked(message: String) {
        delegate?.interstitialVideoClicked(message: message)
    }
    
    public func interstitialVideoClosed(message: String) {
        delegate?.interstitialVideoClosed(message: message)
    }
}
