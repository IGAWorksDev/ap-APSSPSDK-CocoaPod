//
//  GAMMediationInterstitialAd.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class GAMMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitial: AdManagerInterstitialAd?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        if interstitial != nil {
            interstitial?.present(from: from)
            completion()
        } else {
            delegate?.interstitialShowFail(message: "GAM Interstitial ShowFail")
        }
    }
    
    func load() {
        let request = AdManagerRequest()
        AdManagerInterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load GAM interstitial ad with error: \(error.localizedDescription)")
                delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            delegate?.interstitialLoadSuccess()
        })
    }
}

extension GAMMediationInterstitialAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialShowSuccess(message: "GAM ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("GAM Interstitial Error: \(error.localizedDescription)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClicked(message: "GAM Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClosed(message: "GAM Closed")
    }
}
