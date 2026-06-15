//
//  MaioMediationRewardVideoAd.swift
//  MediationMaio
//
//  compatible with MaioSDK v2
//

import UIKit

import APSSPSDK
import Maio


final class MaioMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private var rewardedAd: MaioRewarded?
    
    private let zoneId: String
    
    private let rootViewController: UIViewController?
    
    
    init(zoneId: String, rootViewController: UIViewController?) {
        self.zoneId = zoneId
        self.rootViewController = rootViewController
    }
    
    func load() {
        guard !zoneId.isEmpty else {
            APLogger.error("Maio RewardVideo invalid zoneId")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "Maio RewardVideo invalid zoneId")
            return
        }
        
        APLogger.debug("Start Maio RewardVideo load, zoneId: \(zoneId)")
        
        let request = MaioRequest(zoneId: zoneId, testMode: false)
        rewardedAd = MaioRewarded.loadAd(request: request, callback: self)
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let rewardedAd else {
            delegate?.rewardVideoShowFail(message: "Maio RewardVideo ShowFail - No Ad Loaded")
            return
        }
        rewardedAd.show(viewContext: from, callback: self)
    }
}


// MARK: - MaioRewardedLoadCallback, MaioRewardedShowCallback
extension MaioMediationRewardVideoAd: MaioRewardedLoadCallback, MaioRewardedShowCallback {
    
    func didLoad(_ ad: MaioRewarded) {
        APLogger.debug("Maio RewardVideo didLoad")
        delegate?.rewardVideoLoadSuccess()
    }
    
    func didFail(_ ad: MaioRewarded, errorCode: Int) {
        APLogger.error("Maio RewardVideo didFail: \(errorCode)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "Maio error code: \(errorCode)")
    }
    
    func didOpen(_ ad: MaioRewarded) {
        APLogger.debug("Maio RewardVideo didOpen")
        delegate?.rewardVideoShowSuccess(message: "Maio RewardVideo ShowSuccess")
    }
    
    func didClose(_ ad: MaioRewarded) {
        APLogger.debug("Maio RewardVideo didClose")
        delegate?.rewardVideoClosed(message: "Maio RewardVideo Closed")
    }
    
    func didReward(_ ad: MaioRewarded, reward: RewardData) {
        APLogger.debug("Maio RewardVideo didReward")
        delegate?.rewardVideoCompleted()
    }
}
