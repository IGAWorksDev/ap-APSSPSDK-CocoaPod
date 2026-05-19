//
//  AppLovinMaxInterstitialAdapter.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK


final public class AppLovinMaxInterstitialAdapter: APSSPInterstitialAdapterProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitialAd: AppLovinMaxMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appLovinUnitId.rawValue] ?? ""
        interstitialAd = AppLovinMaxMediationInterstitialAd(placementId: placementId)
        self.interstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.interstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        interstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        interstitialAd?.present(from: from) { completion() }
    }
    
}


extension AppLovinMaxInterstitialAdapter: APSSPInterstitialAdapterDelegate {
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
