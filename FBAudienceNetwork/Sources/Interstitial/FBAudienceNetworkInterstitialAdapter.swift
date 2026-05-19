//
//  FBAudienceNetworkInterstitialAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK


final public class FBAudienceNetworkInterstitialAdapter: APSSPInterstitialAdapterInappBiddingProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitialAd: FBAudienceNetworkMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        interstitialAd = FBAudienceNetworkMediationInterstitialAd(placementId: placementId)
        self.interstitialAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.facebookPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        interstitialAd = FBAudienceNetworkMediationInterstitialAd(placementId: placementId, biddingData: biddingData)
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
    
    public func getBiddingToken() -> String {
        return interstitialAd?.getBiddingToken() ?? ""
    }
}


extension FBAudienceNetworkInterstitialAdapter: APSSPInterstitialAdapterDelegate {
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
