//
//  AdMobMediationInterstitialAd.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdMobMediationInterstitialAd: NSObject {
    
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
            delegate?.interstitialShowFail(message: "AdMob Intersititial ShowFail")
        }
    }
    
    func load() {
        let request = AdManagerRequest()
        AdManagerInterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                
                delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            delegate?.interstitialLoadSuccess()
        }
        )
    }
}

extension AdMobMediationInterstitialAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialShowSuccess(message: "AdMob ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdMob Interstitial Error: \(error.localizedDescription)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClicked(message: "adMob Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClosed(message: "AdMob Closed")
    }
    
}
