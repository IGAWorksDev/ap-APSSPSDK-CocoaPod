//
//  FBAudienceNetworkMediationRewardVideoAd.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import FBAudienceNetwork


final class FBAudienceNetworkMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private var rewardedVideoAd: FBRewardedVideoAd?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var biddingData: String?
    
    
    init(placementId: String, biddingData: String? = nil, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.biddingData = biddingData
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let rewardedVideoAd = rewardedVideoAd, rewardedVideoAd.isAdValid else {
            delegate?.rewardVideoShowFail(message: "FBAudienceNetwork rewardVideo show fail")
          return
        }
        rewardedVideoAd.show(fromRootViewController: from)
        delegate?.rewardVideoShowSuccess(message: "FBAudienceNetwork RewardVideo show")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FBAudienceNetwork RewardVideo placementId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        rewardedVideoAd = FBRewardedVideoAd(placementID: placementId)
        rewardedVideoAd?.delegate = self
        
        APLogger.debug("Start FBAudienceNetwork RewardVideo load,  placementId: \(placementId)")
        
        if let biddingData {
            rewardedVideoAd?.load(withBidPayload: biddingData)
        } else {
            rewardedVideoAd?.load(withBidPayload: "")
        }
    }
    
    func getBiddingToken() -> String {
        return FBAdSettings.bidderToken
    }
}


extension FBAudienceNetworkMediationRewardVideoAd: FBRewardedVideoAdDelegate {
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        delegate?.rewardVideoLoadSuccess()
    }

    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        APLogger.error("FBAudienceNetwork RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        delegate?.rewardVideoClicked(message: "FBAudienceNetwork is Clicked")
    }

    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        delegate?.rewardVideoClosed(message: "FBAudienceNetwork is closed")
    }

    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        delegate?.rewardVideoCompleted()
    }
}
