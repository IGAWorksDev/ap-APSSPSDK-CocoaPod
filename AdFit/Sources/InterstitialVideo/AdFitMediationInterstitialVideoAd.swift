//
//  AdFitMediationInterstitialVideoAd.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/11/24.
//

import UIKit

import APSSPSDK


final class AdFitMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private let placementId: String
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {

    }
    
    func load() {
        APLogger.debug("❌ Do not Support AdFit InterstitialVideoAd ❌")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "AdFit does not support InterstitialVideo")
    }
}


extension AdFitMediationInterstitialVideoAd {
    
}
