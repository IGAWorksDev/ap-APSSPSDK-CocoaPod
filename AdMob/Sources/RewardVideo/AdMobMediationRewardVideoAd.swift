//
//  AdMobMediationRewardVideoAd.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdMobMediationRewardVideoAd: NSObject {
    
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
           return print("Ad wasn't ready.")
         }

         // The UIViewController parameter is an optional.
         rewardedAd.present(from: from) {
           let reward = rewardedAd.adReward
           print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
             self.delegate?.rewardVideoCompleted()
             completion()
           }
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("AdMob RewardVideo placementId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        RewardedAd.load(with: placementId,
                           request: Request())
        { [self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            rewardedAd = ad
            print("Rewarded ad loaded.")
            rewardedAd?.fullScreenContentDelegate = self
            self.delegate?.rewardVideoLoadSuccess()
        }
        
        
    }
}


extension AdMobMediationRewardVideoAd: FullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdMob RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoShowFail(message: "AdMob RewardVideo show fail")
    }

    /// Tells the delegate that the ad will present full screen content.
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoShowSuccess(message: "AdMob RewardVideo show")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClosed(message: "AdMob RewardVideo closed")
    }

    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClicked(message: "AdMob RewardVideo clicked")
    }
}
