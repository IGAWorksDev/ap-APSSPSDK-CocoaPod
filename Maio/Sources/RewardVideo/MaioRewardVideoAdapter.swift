//
//  MaioRewardVideoAdapter.swift
//  MediationMaio
//
//  compatible with MaioSDK v2
//

import UIKit

import APSSPSDK


final public class MaioRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {
    
    public var rootViewController: UIViewController?
    
    private var maioMediationRewardVideoAd: MaioMediationRewardVideoAd?
    
    public var delegate: APSSPRewardVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let zoneId = placementDic[APSSPPlacementKey.maioZoneId.rawValue] ?? ""
        self.rootViewController = rootViewController
        maioMediationRewardVideoAd = MaioMediationRewardVideoAd(zoneId: zoneId, rootViewController: rootViewController)
        maioMediationRewardVideoAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        maioMediationRewardVideoAd?.load()
    }
    
    public func disconnectDelegate() {
        maioMediationRewardVideoAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        maioMediationRewardVideoAd?.present(from: from) { completion() }
    }
}


extension MaioRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.rewardVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    
    public func rewardVideoLoadSuccess() {
        delegate?.rewardVideoLoadSuccess()
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
