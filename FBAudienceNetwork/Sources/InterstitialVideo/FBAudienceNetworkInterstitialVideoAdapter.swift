//
//  FBAudienceNetworkInterstitialVideoAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 4/29/24.
//

import UIKit

import APSSPSDK


final public class FBAudienceNetworkInterstitialVideoAdapter: APSSPInterstitialVideoAdapterInappBiddingProtocol {
   
    private var interstitialVideoAd: FBAudienceNetworkMediationInterstitialVideoAd?
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        interstitialVideoAd = FBAudienceNetworkMediationInterstitialVideoAd(placementId: placementId)
        self.interstitialVideoAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.facebookPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        interstitialVideoAd = FBAudienceNetworkMediationInterstitialVideoAd(placementId: placementId, biddingData: biddingData)
        self.interstitialVideoAd?.delegate = self
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        interstitialVideoAd?.present(from: from) { completion() }
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        self.interstitialVideoAd?.load()
    }

    public func disconnectDelegate() {
        interstitialVideoAd?.delegate = nil
        delegate = nil
    }
    
    public func getBiddingToken() -> String {
        return interstitialVideoAd?.getBiddingToken() ?? ""
    }
}


extension FBAudienceNetworkInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    
    public func interstitialVideoLoadSuccess() {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func interstitialVideoShowSuccess(message: String) {
        delegate?.interstitialVideoShowSuccess(message: message)
    }
    
    public func interstitialVideoShowFail(message: String) {
        delegate?.interstitialVideoShowFail(message: message)
    }
    
    public func interstitialVideoClicked(message: String) {
        delegate?.interstitialVideoClicked(message: message)
    }
    
    public func interstitialVideoClosed(message: String) {
        delegate?.interstitialVideoClosed(message: message)
    }
}
