//
//  FBAudienceNetworkMediationInterstitialVideoAd.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import FBAudienceNetwork


final class FBAudienceNetworkMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialVideo: FBInterstitialAd?
    
    private let placementId: String
    
    private var biddingData: String?
    
    
    init(placementId: String, biddingData: String? = nil) {
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let interstitialVideo, interstitialVideo.isAdValid else {
            delegate?.interstitialVideoShowFail(message: "FBAudienceNetwork interstitialVideo ShowFail")
          return
        }
        interstitialVideo.show(fromRootViewController: from)
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FBAudienceNetwork InterstitialVideo placementId is empty")
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        interstitialVideo = FBInterstitialAd(placementID: placementId)
        interstitialVideo?.delegate = self

        APLogger.debug("Start FBAudienceNetwork InterstitialVideo load,  placementId: \(placementId)")
        
        if let biddingData {
            interstitialVideo?.load(withBidPayload: biddingData)
        } else {
            interstitialVideo?.load(withBidPayload: "")
        }
    }
    
    func getBiddingToken() -> String {
        return FBAdSettings.bidderToken
    }
}


extension FBAudienceNetworkMediationInterstitialVideoAd: FBInterstitialAdDelegate {
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialVideoShowSuccess(message: "FBAudienceNetwork InterstitialVideo ShowSuccess")
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        APLogger.error("FBAudienceNetwork InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialVideoClicked(message: "FBAudienceNetwork Click")
    }

    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialVideoClosed(message: "FBAudienceNetwork Closed")
    }
}
