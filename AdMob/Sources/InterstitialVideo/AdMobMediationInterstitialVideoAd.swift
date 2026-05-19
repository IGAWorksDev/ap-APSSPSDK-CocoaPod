//
//  AdMobMediationInterstitialVideoAd.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/10/17.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdMobMediationInterstitialVideoAd: NSObject {
    
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
            delegate?.interstitialVideoShowFail(message: "AdMob Intersititial ShowFail")
        }
    }
    
    func load() {
        let request = AdManagerRequest()
        AdManagerInterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                
                delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitialVideo = ad
            interstitialVideo?.fullScreenContentDelegate = self
            delegate?.interstitialVideoLoadSuccess()
        })
    }
}


extension AdMobMediationInterstitialVideoAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoShowSuccess(message: "AdMob ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdMob InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClicked(message: "adMob Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClosed(message: "AdMob Closed")
    }
    
}
