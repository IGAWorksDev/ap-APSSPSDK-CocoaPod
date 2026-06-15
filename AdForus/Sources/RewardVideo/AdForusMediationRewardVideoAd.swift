//
//  AdForusMediationRewardVideoAd.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdForusMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private var rewardedAd: RewardedAd?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            return print("AdForus rewarded ad wasn't ready.")
        }

        rewardedAd.present(from: from) {
            let reward = rewardedAd.adReward
            print("AdForus Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            self.delegate?.rewardVideoCompleted()
            completion()
        }
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AdForus RewardVideo placementId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        RewardedAd.load(with: placementId,
                           request: Request())
        { [self] ad, error in
            if let error = error {
                print("Failed to load AdForus rewarded ad with error: \(error.localizedDescription)")
                return
            }
            rewardedAd = ad
            print("AdForus Rewarded ad loaded.")
            rewardedAd?.fullScreenContentDelegate = self
            self.delegate?.rewardVideoLoadSuccess()
        }
    }
}


extension AdForusMediationRewardVideoAd: FullScreenContentDelegate {
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdForus RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoShowFail(message: "AdForus RewardVideo show fail")
    }

    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoShowSuccess(message: "AdForus RewardVideo show")
    }

    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClosed(message: "AdForus RewardVideo closed")
    }

    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClicked(message: "AdForus RewardVideo clicked")
    }
}
