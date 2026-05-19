//
//  VungleMediationInterstitialAd.swift
//  MediationVungle
//

import UIKit

import APSSPSDK
import VungleAdsSDK


final class VungleMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitialAd: VungleInterstitial?
    
    private let placementId: String
    
    private var biddingData: String?
    
    
    init(placementId: String, biddingData: String? = nil) {
        self.placementId = placementId
        self.biddingData = biddingData
    }
    
    func present(from: UIViewController, completion: () -> Void) {
        self.interstitialAd?.present(with: from)
    }
    
    func load() {
        self.interstitialAd = VungleInterstitial(placementId: placementId)
        self.interstitialAd?.delegate = self
        APLogger.debug("Start Vungle Interstitial load,  placementId: \(placementId)")
        
        if let biddingData {
            self.interstitialAd?.load(biddingData)
        } else {
            self.interstitialAd?.load()
        }
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


extension VungleMediationInterstitialAd: VungleInterstitialDelegate {
    
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        delegate?.interstitialLoadSuccess()
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError: NSError) {
        APLogger.error("Vungle Interstitial Error: \(withError.localizedDescription)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func interstitialAdDidTrackImpression(_ interstitial: VungleInterstitial) {
        delegate?.interstitialShowSuccess(message: "Vungle Interstitial is show")
    }
    
    func interstitialAdDidClick(_ interstitial: VungleInterstitial) {
        delegate?.interstitialClicked(message: "Vungle Interstitial is Click")
    }
    
    func interstitialAdWillClose(_ interstitial: VungleInterstitial) {
        delegate?.interstitialClosed(message: "Vungle Interstitial is closed")
    }
    
    func interstitialAdDidFailToPresent(_ interstitial: VungleInterstitial, withError: NSError) {
        delegate?.interstitialShowFail(message: "Vungle Interstitial show Fail: \(withError.description)")
    }
}
