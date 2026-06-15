//
//  AppLovinMediationInterstitialVideoAd.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK


final class AppLovinMaxMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private let placementId: String
    private let price: String
    
    private var interstitialVideoAd: MAInterstitialAd?
    
    private let priceParam = "jC7Fp"
    private let disableAutoRetriesParam = "disable_auto_retries"
    
    init(placementId: String, price: String) {
        self.placementId = placementId
        self.price = price
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let interstitialVideoAd else { return }
        if interstitialVideoAd.isReady {
            interstitialVideoAd.show()
        }
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AppLovinMax InterstitialVideo Ad Unit ID is empty")
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "Ad Unit ID is empty")
            return
        }
        
        interstitialVideoAd = MAInterstitialAd(adUnitIdentifier: placementId)
        interstitialVideoAd?.delegate = self
        interstitialVideoAd?.setExtraParameterForKey(disableAutoRetriesParam, value: "true")
        interstitialVideoAd?.setExtraParameterForKey(priceParam, value: price)
        interstitialVideoAd?.load()
    }
}


extension AppLovinMaxMediationInterstitialVideoAd : MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovinMax interstitialVideoAd Error: \(error.description)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.interstitialVideoShowSuccess(message: "AppLovinMax interstitialVideoAd showSuccess")
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.interstitialVideoClicked(message: "AppLovinMax interstitialVideoAd Click")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        APLogger.error("AppLovinMax interstitialVideoAd Error: \(error.description)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.interstitialVideoClosed(message: "AppLovinMax interstitialVideoAd Closed")
    }
}
