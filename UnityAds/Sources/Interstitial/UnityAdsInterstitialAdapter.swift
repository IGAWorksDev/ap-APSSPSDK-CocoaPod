//
//  UnityAdsInterstitialAdapter.swift
//  MediationUnityAds
//
//  Created by Odin.송황호 on 6/25/24.
//

import UIKit
import APSSPSDK


final public class UnityAdsInterstitialAdapter: APSSPInterstitialAdapterInappBiddingProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var unityAdsMediationInterstitialAd: UnityAdsMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.unityPlacementId.rawValue] ?? ""
        let gameID = placementDic[APSSPPlacementKey.unityGameId.rawValue] ?? ""
        unityAdsMediationInterstitialAd = UnityAdsMediationInterstitialAd(gameID: gameID, placementId: placementId)
        self.unityAdsMediationInterstitialAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.unityPlacementId.rawValue] ?? ""
        let gameID = inappbiddingPlacementDic[APSSPBiddingKey.unityGameId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        unityAdsMediationInterstitialAd = UnityAdsMediationInterstitialAd(gameID: gameID, placementId: placementId, biddingData: biddingData)
        self.unityAdsMediationInterstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.unityAdsMediationInterstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        unityAdsMediationInterstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        unityAdsMediationInterstitialAd?.present(from: from) { completion() }
    }
    
    public func getBiddingToken() -> String {
        return unityAdsMediationInterstitialAd?.getBiddingToken() ?? ""
    }
}


extension UnityAdsInterstitialAdapter: APSSPInterstitialAdapterDelegate {
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
