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
             self.delegate?.rewardVideoCompleted()
             completion()
         }
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("ADOP RewardVideo placementId is empty")
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
            rewardedInterstitialAd = ad
            print("Rewarded ad loaded.")
            rewardedInterstitialAd?.fullScreenContentDelegate = self
            self.delegate?.rewardVideoLoadSuccess()
        }
    }
}


extension ADOPMediationRewardVideoAd: FullScreenContentDelegate {
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("ADOP RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoShowFail(message: "ADOP RewardVideo show fail")
    }

    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoShowSuccess(message: "ADOP RewardVideo show")
    }

    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClosed(message: "ADOP RewardVideo closed")
    }

    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.rewardVideoClicked(message: "ADOP RewardVideo clicked")
    }
}
