//
//  GAMMediationRewardVideoAd.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class GAMMediationRewardVideoAd: NSObject {
    
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
            return print("GAM RewardedAd wasn't ready.")
        }

        rewardedAd.present(from: from) {
            let reward = rewardedAd.adReward
            print("GAM Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            completion()
        }
    }
    
    func load() {
        RewardedAd.load(with: placementId,
                           request: AdManagerRequest())
        { [self] ad, error in
            if let error = error {
                print("Failed to load GAM rewarded ad with error: \(error.localizedDescription)")
                return
            }
            rewardedAd = ad
            print("GAM Rewarded ad loaded.")
            rewardedAd?.fullScreenContentDelegate = self
            self.delegate?.rewardVideoLoadSuccess()
        }
    }
}


extension GAMMediationRewardVideoAd: FullScreenContentDelegate {
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("GAM RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    }

    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    }
}
