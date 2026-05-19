//
//  VungleMediationInterstitialVideoAd.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK
import VungleAdsSDK


final class VungleMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialAd: VungleInterstitial?
    
    private let placementId: String
    
    private var biddingData: String?
    
    
    init(placementId: String, biddingData: String? = nil) {
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
        self.interstitialAd?.present(with: from)
    }
    
    func load() {
        self.interstitialAd = VungleInterstitial(placementId: placementId)
        self.interstitialAd?.delegate = self
        APLogger.debug("Start Vungle InterstitialVideo load,  UnitID: \(placementId)")
        self.interstitialAd?.load()
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


extension VungleMediationInterstitialVideoAd: VungleInterstitialDelegate {
    
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError: NSError) {
        APLogger.error("Vungle InterstitialVideo Error: \(withError.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func interstitialAdDidTrackImpression(_ interstitial: VungleInterstitial) {
        delegate?.interstitialVideoShowSuccess(message: "Vungle InterstitialVideo is show")
    }
    
    func interstitialAdDidClick(_ interstitial: VungleInterstitial) {
        delegate?.interstitialVideoClicked(message: "Vungle InterstitialVideo is Click")
    }
    
    func interstitialAdWillClose(_ interstitial: VungleInterstitial) {
        delegate?.interstitialVideoClosed(message: "Vungle InterstitialVideo is closed")
    }
    
    func interstitialAdDidFailToPresent(_ interstitial: VungleInterstitial, withError: NSError) {
        delegate?.interstitialVideoShowFail(message: "Vungle InterstitialVideo show Fail,: \(withError.description)")
    }
}
