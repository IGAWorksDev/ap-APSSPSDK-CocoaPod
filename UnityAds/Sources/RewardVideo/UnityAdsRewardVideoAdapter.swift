//
//  UnityAdsRewardVideoAdapter.swift
//  MediationUnityAds
//
//  Created by Odin.송황호 on 6/25/24.
//

import UIKit

import APSSPSDK


final public class UnityAdsRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {
    public var rootViewController: UIViewController?

    private var rewardVideoAd: UnityAdsMediationRewardVideoAd?
    
    public var delegate: APSSPRewardVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.unityPlacementId.rawValue] ?? ""
        let gameID = placementDic[APSSPPlacementKey.unityGameId.rawValue] ?? ""
        rewardVideoAd = UnityAdsMediationRewardVideoAd(gameID: gameID, placementId: placementId)
        self.rewardVideoAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        self.rewardVideoAd?.load()
    }

    public func disconnectDelegate() {
        rewardVideoAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping() -> Void) {
        rewardVideoAd?.present(from: from) { completion() }
    }
    
}




extension UnityAdsRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() {
        delegate?.rewardVideoLoadSuccess()
    }
    
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.rewardVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func rewardVideoShowSuccess(message: String) {
        delegate?.rewardVideoShowSuccess(message: message)
    }
    
    public func rewardVideoShowFail(message: String) {
        delegate?.rewardVideoShowFail(message: message)
    }
    
    public func rewardVideoClicked(message: String) {
        delegate?.rewardVideoClicked(message: message)
    }
    
    public func rewardVideoClosed(message: String) {
        delegate?.rewardVideoClosed(message: message)
    }
    
    public func rewardVideoCompleted() {
        delegate?.rewardVideoCompleted()
    }
}
