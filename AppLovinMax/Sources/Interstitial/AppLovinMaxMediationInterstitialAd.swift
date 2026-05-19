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
    
    private var interstitialAd: MAInterstitialAd?
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        guard let interstitialAd else { return }
        if interstitialAd.isReady {
            interstitialAd.show()
        } else {
            
        }
        
    }
    
    func load() {
        interstitialAd = MAInterstitialAd(adUnitIdentifier: placementId)
        interstitialAd?.delegate = self

        interstitialAd?.setExtraParameterForKey("jC7Fp", value: "«value»")
        // Load the first ad
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
    
    func didHide(_ ad: MAAd) { }
}
