//
//  PangleMediationRewardVideoAd.swift
//  MediationPangle
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
//import PAGAdSDK


final class PangleMediationRewardVideoAd: NSObject {
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
//    private var rewardedAd: PAGRewardedAd?
    
    private let appID: String
    
    private let placementId: String
    
    private var biddingData: String?
    
    init(appID: String, placementId: String, biddingData: String? = nil) {
        self.appID = appID
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
//        rewardedAd?.present(fromRootViewController: from)
    }
    
    func load() {
//        let request = PAGRewardedRequest()
//        if let biddingData {
//            request.adString = biddingData
//        }
//        PAGRewardedAd.load(withSlotID: placementId, request: request) { [weak self] rewardedAd, error in
//            if let error {
//                APLogger.error("Pangle RewardVideo Error: \(error.localizedDescription)")
//                self?.delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: nil)
//                return
//            }
//            self?.rewardedAd = rewardedAd
//            self?.rewardedAd?.delegate = self
//            self?.delegate?.rewardVideoLoadSuccess()
//        }
    }
    
    func getBiddingToken() -> String {
//        return PAGSdk.getBiddingToken(nil) ?? ""
        return ""
    }
}
