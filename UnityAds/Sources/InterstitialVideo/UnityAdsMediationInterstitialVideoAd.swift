//
//  UnityAdsMediationInterstitialVideoAd.swift
//  MediationUnityAds
//
//  Created by Odin.송황호 on 6/25/24.
//

import UIKit

import APSSPSDK
import UnityAds


final class UnityAdsMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private let gameID: String
    
    private let placementId: String
    
    private var unityAdsInitialization = UnityAdsInitializationAdpater()
    
    init(gameID: String, placementId: String) {
        self.gameID = gameID
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
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


extension UnityAdsMediationInterstitialVideoAd: UnityAdsLoadDelegate, UnityAdsShowDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        APLogger.error("UnityAds InterstitialVideo Error: \(message)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: message)
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        delegate?.interstitialVideoClosed(message: "unityAd Closed")
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        APLogger.error("UnityAds InterstitialVideo Error: \(message)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: message)
    }
    
    func unityAdsShowStart(_ placementId: String) {
        delegate?.interstitialVideoShowSuccess(message: "UnityAds show")
    }
    
    func unityAdsShowClick(_ placementId: String) {
        delegate?.interstitialVideoClicked(message: "UnityAds Click")
    }
    
}
