//
//  FBAudienceNetworkRewardVideoAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK


final public class FBAudienceNetworkRewardVideoAdapter: APSSPRewardVideoAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?

    private var rewardVideoAd: FBAudienceNetworkMediationRewardVideoAd?
    
    public var delegate: APSSPRewardVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        rewardVideoAd = FBAudienceNetworkMediationRewardVideoAd(placementId: placementId,
                                                                rootViewController: rootViewController)
        self.rewardVideoAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.facebookPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        rewardVideoAd = FBAudienceNetworkMediationRewardVideoAd(placementId: placementId,
                                                                biddingData: biddingData,
                                                                rootViewController: rootViewController)
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
    
    public func getBiddingToken() -> String {
        return rewardVideoAd?.getBiddingToken() ?? ""
    }
}


extension FBAudienceNetworkRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
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
