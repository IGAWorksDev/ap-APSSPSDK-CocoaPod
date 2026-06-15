//
//  AppLovinMaxMediationInterstitialAd.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK

final class AppLovinMaxMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private let placementId: String
    private let price: String
    
    private var interstitialAd: MAInterstitialAd?
    
    private let priceParam = "jC7Fp"
    private let disableAutoRetriesParam = "disable_auto_retries"
    
    init(placementId: String, price: String) {
        self.placementId = placementId
        self.price = price
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        guard let interstitialAd else { return }
        if interstitialAd.isReady {
            interstitialAd.show()
        } else {
            
        }
        
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AppLovinMax Interstitial Ad Unit ID is empty")
            delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "Ad Unit ID is empty")
            return
        }
        
        interstitialAd = MAInterstitialAd(adUnitIdentifier: placementId)
        interstitialAd?.delegate = self
        interstitialAd?.setExtraParameterForKey(disableAutoRetriesParam, value: "true")
        interstitialAd?.setExtraParameterForKey(priceParam, value: price)
        interstitialAd?.load()
    }
}


extension AppLovinMaxMediationInterstitialAd: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        delegate?.interstitialLoadSuccess()
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovinMax interstitialAd Error: \(error.description)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.interstitialShowSuccess(message: "AppLovinMax interstitialAd showSuccess")
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.interstitialClicked(message: "AppLovinMax interstitialAd Click")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        APLogger.error("AppLovinMax interstitialAd Error: \(error.description)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.interstitialClosed(message: "AppLovinMax interstitialAd Closed")
    }
}
