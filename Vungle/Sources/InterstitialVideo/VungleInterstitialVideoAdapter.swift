//
//  VungleInterstitialVideoAdapter.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/20/24.
//

import UIKit

import APSSPSDK


final public class VungleInterstitialVideoAdapter: APSSPInterstitialVideoAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?

    private var rewardVideoAd: VungleMediationInterstitialVideoAd
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.vunglePlacementId.rawValue] ?? ""
        rewardVideoAd = VungleMediationInterstitialVideoAd(placementId: placementId)
        self.rewardVideoAd.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.vunglePlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        rewardVideoAd = VungleMediationInterstitialVideoAd(placementId: placementId)
        self.rewardVideoAd.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        self.rewardVideoAd.load()
    }

    public func disconnectDelegate() {
        rewardVideoAd.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping() -> Void) {
        rewardVideoAd.present(from: from) { completion() }
    }
    
    public func getBiddingToken() -> String {
        return rewardVideoAd.getBiddingToken()
    }
    
}




extension VungleInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
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
