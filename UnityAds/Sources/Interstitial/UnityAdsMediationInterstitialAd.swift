//
//  UnityAdsMediationInterstitialAd.swift
//  MediationUnityAds
//
//  Created by Odin.송황호 on 6/25/24.
//


import UIKit

import APSSPSDK
import UnityAds


final class UnityAdsMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private let gameID: String
    
    private let placementId: String
    
    private var unityAdsInitialization = UnityAdsInitializationAdpater()
    
    init(gameID: String, placementId: String) {
        self.gameID = gameID
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        UnityAds.show(from, placementId: placementId, showDelegate: self)
    }
    
    func load() {
        if UnityAds.isInitialized() {
            UnityAds.load(placementId, loadDelegate: self)
        } else {
            unityAdsInitialization.start(keys: ["appKey": gameID]) { _, _ in }
        }
    }
    
}


extension UnityAdsMediationInterstitialAd: UnityAdsLoadDelegate, UnityAdsShowDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        delegate?.interstitialLoadSuccess()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        APLogger.error("unityAd Interstitial Error: \(message)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: message)
    }
    
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        delegate?.interstitialClosed(message: "unityAd Closed")
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        APLogger.error("unityAd Interstitial Error: \(message)")
        delegate?.interstitialShowFail(message: "unityAd Interstital show fail")
    }
    
    func unityAdsShowStart(_ placementId: String) {
        delegate?.interstitialShowSuccess(message: "unityAd Show")
    }
    
    func unityAdsShowClick(_ placementId: String) {
        delegate?.interstitialClicked(message: "unityAd Click")
    }
    
}
