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
    
    private var incentivizedAd: ALIncentivizedInterstitialAd?
    
    /// Reward 검증 결과 (showAndNotify 후 ALAdRewardDelegate에서 설정됨)
    private var isRewardVerified: Bool = false
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init()
        
        // ZoneId가 있으면 해당 ZoneId로 인스턴스 생성
        if !placementId.isEmpty {
            self.incentivizedAd = ALIncentivizedInterstitialAd(zoneIdentifier: placementId)
        } else {
            self.incentivizedAd = ALIncentivizedInterstitialAd.shared()
        }
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let incentivizedAd = incentivizedAd else {
            delegate?.rewardVideoShowFail(message: "AppLovin RewardVideo not initialized")
            return
        }
        
        // Reward 검증 플래그 초기화
        isRewardVerified = false
        
        if incentivizedAd.isReadyForDisplay {
            incentivizedAd.adDisplayDelegate = self
            incentivizedAd.adVideoPlaybackDelegate = self
            // showAndNotify를 사용해야 ALAdRewardDelegate 콜백을 받을 수 있음
            incentivizedAd.showAndNotify(self)
        } else {
            delegate?.rewardVideoShowFail(message: "AppLovin RewardVideo not ready")
        }
    }
    
    func load() {
        incentivizedAd?.preloadAndNotify(self)
    }
        
}


// MARK: - ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate

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
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        delegate?.rewardVideoClosed(message: "AppLovin RewardVideo Closed")
    }

    func videoPlaybackBegan(in ad: ALAd) { }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) {
        APLogger.debug("AppLovin RewardVideo videoPlaybackEnded isRewardVerified: \(isRewardVerified), wasFullyWatched: \(wasFullyWatched)")
        // ObjC와 동일하게 isRewardVerified 기준으로 completed 호출
        if isRewardVerified {
            delegate?.rewardVideoCompleted()
        }
    }
    
}


// MARK: - ALAdRewardDelegate

extension AppLovinMediationRewardVideoAd: ALAdRewardDelegate {
    
    func rewardValidationRequest(for ad: ALAd, didSucceedWithResponse response: [AnyHashable : Any]) {
        APLogger.debug("AppLovin RewardVideo rewardValidationRequest didSucceedWithResponse")
        isRewardVerified = true
    }
    
    func rewardValidationRequest(for ad: ALAd, wasRejectedWithResponse response: [AnyHashable : Any]) {
        APLogger.debug("AppLovin RewardVideo rewardValidationRequest wasRejectedWithResponse")
    }
    
    func rewardValidationRequest(for ad: ALAd, didExceedQuotaWithResponse response: [AnyHashable : Any]) {
        APLogger.debug("AppLovin RewardVideo rewardValidationRequest didExceedQuotaWithResponse: \(response)")
    }
    
    func rewardValidationRequest(for ad: ALAd, didFailWithError responseCode: Int) {
        APLogger.debug("AppLovin RewardVideo rewardValidationRequest didFailWithError: \(responseCode)")
    }
    
}
