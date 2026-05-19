//
//  AdForusMediationInterstitialAd.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdForusMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitial: InterstitialAd?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        if interstitial != nil {
            interstitial?.present(from: from)
            completion()
        } else {
            delegate?.interstitialShowFail(message: "AdForus Interstitial ShowFail")
        }
    }
    
    func load() {
        let request = Request()
        InterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load AdForus interstitial ad with error: \(error.localizedDescription)")
                delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            delegate?.interstitialLoadSuccess()
        })
    }
}

extension AdForusMediationInterstitialAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialShowSuccess(message: "AdForus ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdForus Interstitial Error: \(error.localizedDescription)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClicked(message: "AdForus Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialClosed(message: "AdForus Closed")
    }
}
