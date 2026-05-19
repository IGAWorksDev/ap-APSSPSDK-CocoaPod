//
//  AppLovinMediationRewardVideoAd.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK


final class AppLovinMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var rewardVideoAd: ALAd?
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if ALIncentivizedInterstitialAd.isReadyForDisplay() {
            // Show call not using a reward delegate
            ALIncentivizedInterstitialAd.shared().adDisplayDelegate = self
            ALIncentivizedInterstitialAd.shared().adVideoPlaybackDelegate = self
            ALIncentivizedInterstitialAd.show()

        }
        else {
            delegate?.rewardVideoShowFail(message: "")
        }
    }
    
    func load() {
        ALIncentivizedInterstitialAd.preloadAndNotify(self)
        
    }
        
}


extension AppLovinMediationRewardVideoAd: ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate {
    
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        rewardVideoAd = ad
        delegate?.rewardVideoLoadSuccess()
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        APLogger.error("AppLovin RewardVideo Error: \(APAppLovinError.init(rawValue: code) ?? .error)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "AppLovin load failed with code: \(code)")
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.rewardVideoShowSuccess(message: "AppLovin RewardVideo showSuccess")
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.rewardVideoClicked(message: "AppLovin RewardVideo Click")
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) { }

    func videoPlaybackBegan(in ad: ALAd) { }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) { }
    
}
