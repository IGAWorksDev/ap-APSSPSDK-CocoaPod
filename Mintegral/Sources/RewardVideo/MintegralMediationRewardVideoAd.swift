//
//  MintegralMediationRewardVideoAd.swift
//  MediationMintegral
//
//  Created by Odin.송황호 on 7/8/24.
//

import UIKit

import APSSPSDK
import MTGSDKReward


final class MintegralMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let unitID: String
    
    private let rewardID: String
    
    private let rootViewController: UIViewController?
    
    private var rewardVideoAd = MTGRewardAdManager.sharedInstance()
    
    
    init(placementId: String, unitID: String, rewardID: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.unitID = unitID
        self.rewardID = rewardID
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if rewardVideoAd.isVideoReadyToPlay(withPlacementId: placementId, unitId: unitID) {
            rewardVideoAd.showVideo(withPlacementId: placementId,
                                    unitId: unitID,
                                    withRewardId: rewardID,
                                    userId: "",
                                    delegate: self,
                                    viewController: from)
        }
        else {
            delegate?.rewardVideoShowFail(message: "")
        }
    }
    
    func load() {
        APLogger.debug("Start Mintegral RewardVideo load,  placementId: \(placementId), unitId: \(unitID), rewardID: \(rewardID)")
        rewardVideoAd.loadVideo(withPlacementId: placementId, unitId: unitID, delegate: self)
    }
        
}


extension MintegralMediationRewardVideoAd: MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate {
    func onAdLoadSuccess(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoLoadSuccess()
    }
    
    func onVideoAdLoadFailed(_ placementId: String?, unitId: String?, error: any Error) {
        APLogger.error("Mintegra RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func onVideoAdShowSuccess(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoShowSuccess(message: "Mintegral RewardVideo ShowSuccess")
    }
    
    func onVideoAdShowFailed(_ placementId: String?, unitId: String?, withError error: any Error) {
        APLogger.error("Mintegra RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func onVideoAdClicked(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoClicked(message: "Mintegral RewardVideo Click")
    }
    
    func onVideoAdDidClosed(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoClosed(message: "Mintegral RewardVideo Closed")
    }
    
    func onVideoPlayCompleted(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoCompleted()
    }

}
