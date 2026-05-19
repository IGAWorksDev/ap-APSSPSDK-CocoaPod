//
//  AdMobRewardVideoAdapter.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK


final public class AdMobRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {
    public var rootViewController: UIViewController?

    private var adMobMediationRewardVideoAd: AdMobMediationRewardVideoAd?
    
    public var delegate: APSSPRewardVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        adMobMediationRewardVideoAd = AdMobMediationRewardVideoAd(placementId: placementId, rootViewController: rootViewController)
        self.adMobMediationRewardVideoAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        self.adMobMediationRewardVideoAd?.load()
    }

    public func disconnectDelegate() {
        adMobMediationRewardVideoAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping() -> Void) {
        adMobMediationRewardVideoAd?.present(from: from) { completion() }
    }
    
}




extension AdMobRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
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
