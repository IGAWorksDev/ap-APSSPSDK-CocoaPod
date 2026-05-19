//
//  VungleMediationRewardVideoAd.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK
import VungleAdsSDK


final class VungleMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var rewardedAd: VungleRewarded?
    
    private var biddingData: String?
    
    
    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
        
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        self.rewardedAd?.present(with: from)
        completion()
    }
    
    func load() {
        self.rewardedAd = VungleRewarded(placementId: placementId)
        self.rewardedAd?.delegate = self
        APLogger.debug("Start Vungle rewardvideo load,  UnitID: \(placementId)")
        self.rewardedAd?.load()
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


extension VungleMediationRewardVideoAd: VungleRewardedDelegate {
    // Ad load events
    func rewardedAdDidLoad(_ rewarded: VungleRewarded) {
        delegate?.rewardVideoLoadSuccess()
    }
    
    func rewardedAdDidFailToLoad(_ rewarded: VungleRewarded, withError: NSError) {
        APLogger.error("Vungle RewardVideo Error: \(withError.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func rewardedAdDidPresent(_ rewarded: VungleRewarded) {
        delegate?.rewardVideoShowSuccess(message: "Vungle RewardVideo is show")
    }
    
    func rewardedAdDidFailToPresent(_ rewarded: VungleRewarded, withError: NSError) {
        APLogger.error("Vungle RewardVideo Error: \(withError.localizedDescription)")
        delegate?.rewardVideoShowFail(message: "Vungle RewardVideo show Fail")
    }
    
    func rewardedAdDidClick(_ rewarded: VungleRewarded) {
        delegate?.rewardVideoClicked(message: "Vungle RewardVideo is click")
    }
    
    func rewardedAdDidClose(_ rewarded: VungleRewarded) {
        delegate?.rewardVideoClosed(message: "Vungle RewardVideo is closed")
    }
}
