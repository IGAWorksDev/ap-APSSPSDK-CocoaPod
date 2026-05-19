//
//  AppLovinInterstitialAdapter.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK


final public class AppLovinInterstitialAdapter: APSSPInterstitialAdapterProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var applovinMediationInterstitialAd: AppLovinMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appLovinZoneId.rawValue] ?? ""
        applovinMediationInterstitialAd = AppLovinMediationInterstitialAd(placementId: placementId)
        self.applovinMediationInterstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.applovinMediationInterstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        applovinMediationInterstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        applovinMediationInterstitialAd?.present(from: from) { completion() }
    }
    
}


extension AppLovinInterstitialAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() {
        delegate?.interstitialLoadSuccess()
    }
    
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func interstitialShowSuccess(message: String) {
        delegate?.interstitialShowSuccess(message: message)
    }
    
    public func interstitialShowFail(message: String) {
        delegate?.interstitialShowFail(message: message)
    }
    
    public func interstitialClicked(message: String) {
        delegate?.interstitialClicked(message: message)
    }
    
    public func interstitialClosed(message: String) {
        delegate?.interstitialClosed(message: message)
    }
}
