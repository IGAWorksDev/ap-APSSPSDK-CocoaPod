//
//  AdFitMeidationInterstitialAd.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/11/24.
//

import UIKit

import APSSPSDK


final class AdFitMeidationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {

    }
    
    func load() {
        APLogger.debug("❌ Do not Support AdFit InterstitialAd ❌")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "AdFit does not support Interstitial")
    }
}


extension AdFitMeidationInterstitialAd {
    
}
