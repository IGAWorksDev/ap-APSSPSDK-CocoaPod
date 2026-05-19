//
//  AdMobMediationRewardVideoAd.swift
//  MediationADOP
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class ADOPMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private var rewardedInterstitialAd: RewardedAd?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let rewardedInterstitialAd = rewardedInterstitialAd else {
           return print("Ad wasn't ready.")
         }

         // The UIViewController parameter is an optional.
         rewardedInterstitialAd.present(from: from) {
           let reward = rewardedInterstitialAd.adReward
           print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
             completion()
           // TODO: Reward the user.
         }
    }
    
    func load() {
        
        RewardedAd.load(with: placementId,
                           request: Request())
        { [self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            rewardedInterstitialAd = ad
            print("Rewarded ad loaded.")
            rewardedInterstitialAd?.fullScreenContentDelegate = self
            self.delegate?.rewardVideoLoadSuccess()
        }
    }
}


extension ADOPMediationRewardVideoAd: FullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("ADOP RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    /// Tells the delegate that the ad will present full screen content.
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }
}
