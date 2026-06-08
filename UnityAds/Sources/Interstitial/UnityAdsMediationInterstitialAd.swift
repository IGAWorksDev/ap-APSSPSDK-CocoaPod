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
    private var biddingData: String?
    
    private var unityAdsInitialization = UnityAdsInitializationAdpater()
    private var loadObjectId: String?
    
    init(gameID: String, placementId: String, biddingData: String? = nil) {
        self.gameID = gameID
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        if let objectId = loadObjectId, let showOptions = UADSShowOptions() {
            showOptions.objectId = objectId
            UnityAds.show(from, placementId: placementId, options: showOptions, showDelegate: self)
        } else {
            UnityAds.show(from, placementId: placementId, showDelegate: self)
        }
    }
    
    func load() {
        if UnityAds.isInitialized() {
            loadAd()
        } else {
            unityAdsInitialization.start(keys: ["appKey": gameID]) { [weak self] success, _ in
                if success {
                    self?.loadAd()
                } else {
                    self?.delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "UnityAds initialization failed")
                }
            }
        }
    }
    
    private func loadAd() {
        APLogger.debug("Start UnityAds Interstitial load, placementId: \(placementId)")
        
        if let biddingData = biddingData, !biddingData.isEmpty,
           let loadOptions = UADSLoadOptions() {
            let objectId = UUID().uuidString
            loadOptions.adMarkup = biddingData
            loadOptions.objectId = objectId
            self.loadObjectId = objectId
            APLogger.debug("UnityAds Interstitial loading with adMarkup")
            UnityAds.load(placementId, options: loadOptions, loadDelegate: self)
        } else {
            self.loadObjectId = nil
            UnityAds.load(placementId, loadDelegate: self)
        }
    }
    
    func getBiddingToken() -> String {
        return UnityAds.getToken() ?? ""
    }
}


extension UnityAdsMediationInterstitialAd: UnityAdsLoadDelegate, UnityAdsShowDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        delegate?.interstitialLoadSuccess()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        APLogger.error("UnityAds Interstitial Error: \(message)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: message)
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        delegate?.interstitialClosed(message: "UnityAds Closed")
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        APLogger.error("UnityAds Interstitial Error: \(message)")
        delegate?.interstitialShowFail(message: "UnityAds Interstitial show fail")
    }
    
    func unityAdsShowStart(_ placementId: String) {
        delegate?.interstitialShowSuccess(message: "UnityAds Show")
    }
    
    func unityAdsShowClick(_ placementId: String) {
        delegate?.interstitialClicked(message: "UnityAds Click")
    }
}
