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
    
    private var interstitialVideoAd: MAInterstitialAd?
    
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let interstitialVideoAd else { return }
        if interstitialVideoAd.isReady {
            interstitialVideoAd.show()
        }
    }
    
    func load() {
        interstitialVideoAd = MAInterstitialAd(adUnitIdentifier: placementId)
        interstitialVideoAd?.delegate = self

        interstitialVideoAd?.setExtraParameterForKey("jC7Fp", value: "«value»")
        // Load the first ad
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
    
    func didHide(_ ad: MAAd) { }
}
