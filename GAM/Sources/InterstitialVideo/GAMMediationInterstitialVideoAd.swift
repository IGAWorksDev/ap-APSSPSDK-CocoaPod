//
//  GAMMediationInterstitialVideoAd.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class GAMMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialVideo: AdManagerInterstitialAd?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if interstitialVideo != nil {
            interstitialVideo?.present(from: from)
            completion()
        } else {
            delegate?.interstitialVideoShowFail(message: "GAM InterstitialVideo ShowFail")
        }
    }
    
    func load() {
        let request = AdManagerRequest()
        AdManagerInterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load GAM interstitial video ad with error: \(error.localizedDescription)")
                delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitialVideo = ad
            interstitialVideo?.fullScreenContentDelegate = self
            delegate?.interstitialVideoLoadSuccess()
        })
    }
}


extension GAMMediationInterstitialVideoAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoShowSuccess(message: "GAM ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("GAM InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClicked(message: "GAM Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClosed(message: "GAM Closed")
    }
}
