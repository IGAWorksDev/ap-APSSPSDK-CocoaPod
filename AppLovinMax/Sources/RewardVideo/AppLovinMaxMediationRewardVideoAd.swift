//
//  AppLovinMaxMediationRewardVideoAd.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK


final class AppLovinMaxMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var rewardvideoAd: MARewardedAd?
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let rewardvideoAd else { return }
        if rewardvideoAd.isReady {
            rewardvideoAd.show()
        } else {
            delegate?.rewardVideoShowFail(message: "Fail")
        }
    }
    
    func load() {
        rewardvideoAd = MARewardedAd.shared(withAdUnitIdentifier: placementId)
        rewardvideoAd?.delegate = self

        rewardvideoAd?.setExtraParameterForKey("jC7Fp", value: "«value»")

        // Load the first ad
        rewardvideoAd?.load()
    }
        
}


extension AppLovinMaxMediationRewardVideoAd: MARewardedAdDelegate {
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        delegate?.rewardVideoCompleted()
    }
    
    func didLoad(_ ad: MAAd) {
        delegate?.rewardVideoLoadSuccess()
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovinMax RewardVideoAd Error: \(error.description)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.rewardVideoShowSuccess(message: "AppLovinMax RewardVideoAd showSuccess")
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.rewardVideoClicked(message: "AppLovinMax RewardVideoAd Clicked")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        APLogger.error("AppLovinMax RewardVideoAd Error: \(error.description)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.description)
    }

    func didHide(_ ad: MAAd) { }
}
