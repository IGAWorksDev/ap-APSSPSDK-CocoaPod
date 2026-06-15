//
//  InMobiMediationRewardVideoAd.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
import InMobiSDK


final class InMobiMediationRewardVideoAd: NSObject {

    var delegate: APSSPRewardVideoAdapterDelegate?

    private let placementId: String

    private let rootViewController: UIViewController?

    private var rewardedAd: IMInterstitial?


    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("InMobi RewardVideo placementId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi RewardVideo load, placementId: \(pid)")

        rewardedAd = IMInterstitial(placementId: pid)
        rewardedAd?.delegate = self
        rewardedAd?.load()
    }

    func present(from: UIViewController, completion: @escaping () -> Void) {
        rewardedAd?.show(from: from)
        completion()
    }
}


// MARK: - IMInterstitialDelegate
extension InMobiMediationRewardVideoAd: IMInterstitialDelegate {
    
    func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
        delegate?.rewardVideoLoadSuccess()
    }
    
    func interstitial(_ interstitial: IMInterstitial, didFailToLoadWithError error: IMRequestStatus) {
        APLogger.error("InMobi RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func interstitialWillPresent(_ interstitial: IMInterstitial) {
        delegate?.rewardVideoShowSuccess(message: "InMobi RewardVideo is show")
    }
    
    func interstitial(_ interstitial: IMInterstitial, didFailToPresentWithError error: IMRequestStatus) {
        APLogger.error("InMobi RewardVideo show fail: \(error.localizedDescription)")
        delegate?.rewardVideoShowFail(message: "InMobi RewardVideo show Fail")
    }
    
    func interstitialDidDismiss(_ interstitial: IMInterstitial) {
        delegate?.rewardVideoClosed(message: "InMobi RewardVideo is closed")
    }
    
    func interstitialAdWasClicked(_ interstitial: IMInterstitial) {
        delegate?.rewardVideoClicked(message: "InMobi RewardVideo Clicked")
    }
    
    func interstitial(_ interstitial: IMInterstitial, rewardActionCompletedWithRewards rewards: [String: Any]) {
        delegate?.rewardVideoCompleted()
    }
}
