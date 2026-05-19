//
//  PangleAdsMediationInterstitialVideoAd.swift
//  MediationPangle
//
//  Created by Odin.송황호 on 6/25/24.
//

import UIKit

import APSSPSDK
//import PAGAdSDK


final class PangleAdsMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private let appID: String
    
    private let placementId: String
    
    private var biddingData: String?
    
    init(appID: String, placementId: String, biddingData: String? = nil) {
        self.appID = appID
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
//        interstitialAd?.present(fromRootViewController: from)
    }
    
    func load() {
//        let request = PAGLInterstitialRequest()
//        if let biddingData {
//            request.adString = biddingData
//        }
//        PAGLInterstitialAd.load(withSlotID: placementId, request: request) { [weak self] interstitialAd, error in
//            if let error {
//                APLogger.error("Pangle InterstitialVideo Error: \(error.localizedDescription)")
//                self?.delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: nil)
//                return
//            }
//            self?.interstitialAd = interstitialAd
//            self?.interstitialAd?.delegate = self
//            self?.delegate?.interstitialVideoLoadSuccess()
//        }
    }
    
    func getBiddingToken() -> String {
//        return PAGSdk.getBiddingToken(nil) ?? ""
        return ""
    }
}
