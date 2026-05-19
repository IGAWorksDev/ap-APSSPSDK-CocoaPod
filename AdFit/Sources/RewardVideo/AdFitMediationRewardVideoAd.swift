//
//  AdFitMediationRewardVideoAd.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/11/24.
//

import UIKit

import APSSPSDK


final class AdFitMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
    
    }
    
    func load() {
        APLogger.debug("❌ Do not Support AdFit RewardVideoAd ❌")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "AdFit does not support RewardVideo")
    }
        
}


extension AdFitMediationRewardVideoAd {
    
}
