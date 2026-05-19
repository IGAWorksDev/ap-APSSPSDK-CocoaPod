//
//  FBAudienceNetworkMediationInterstitialAd.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import FBAudienceNetwork


final class FBAudienceNetworkMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitial: FBInterstitialAd?
    
    private let placementId: String
    
    private var biddingData: String?
    

    init(placementId: String, biddingData: String? = nil) {
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        guard let interstitial, interstitial.isAdValid else {
            delegate?.interstitialShowFail(message: "FBAudienceNetwork Interstitial ShowFail")
          return
        }
        interstitial.show(fromRootViewController: from)
    }
    
    func load() {
        interstitial = FBInterstitialAd(placementID: placementId)
        interstitial?.delegate = self

        APLogger.debug("Start FBAudienceNetwork Interstitial load,  placementId: \(placementId)")
        
        if let biddingData {
            interstitial?.load(withBidPayload: biddingData)
        } else {
            interstitial?.load(withBidPayload: "")
        }
    }
    
    func getBiddingToken() -> String {
        return FBAdSettings.bidderToken
    }
}

extension FBAudienceNetworkMediationInterstitialAd: FBInterstitialAdDelegate {
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialLoadSuccess()
    }
    
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialShowSuccess(message: "FBAudienceNetwork ShowSuccess")
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        APLogger.error("FBAudienceNetwork Interstitial Error: \(error.localizedDescription)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialClicked(message: "FBAudienceNetwork Click")
    }

    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        delegate?.interstitialClosed(message: "FBAudienceNetwork Closed")
    }
}
