//
//  AdForusMediationInterstitialVideoAd.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdForusMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialVideo: InterstitialAd?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if interstitialVideo != nil {
            interstitialVideo?.present(from: from)
            completion()
        } else {
            delegate?.interstitialVideoShowFail(message: "AdForus InterstitialVideo ShowFail")
        }
    }
    
    func load() {
        let request = Request()
        InterstitialAd.load(with: placementId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load AdForus interstitial video ad with error: \(error.localizedDescription)")
                delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            interstitialVideo = ad
            interstitialVideo?.fullScreenContentDelegate = self
            delegate?.interstitialVideoLoadSuccess()
        })
    }
}


extension AdForusMediationInterstitialVideoAd: FullScreenContentDelegate {
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoShowSuccess(message: "AdForus ShowSuccess")
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        APLogger.error("AdForus InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClicked(message: "AdForus Click")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        delegate?.interstitialVideoClosed(message: "AdForus Closed")
    }
}
