//
//  AppLovinMediationInterstitialAd.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK

final class AppLovinMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private let placementId: String
    
    private var interstitialAd: ALAd?
    
    init(placementId: String) {
        self.placementId = placementId
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        guard let interstitialAd else  {
            delegate?.interstitialShowFail(message: "")
            return
        }
        ALInterstitialAd.shared().adDisplayDelegate = self
        ALInterstitialAd.shared().adVideoPlaybackDelegate = self
        ALInterstitialAd.shared().show(interstitialAd)
    }
    
    func load() {
        ALSdk.shared().adService.loadNextAd(forZoneIdentifier: placementId, andNotify: self)
    }
}


extension AppLovinMediationInterstitialAd: ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        interstitialAd = ad
        delegate?.interstitialLoadSuccess()
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        APLogger.error("AppLovin Interstitial Error: \(APAppLovinError.init(rawValue: code) ?? .error)")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "AppLovin load failed with code: \(code)")
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.interstitialShowSuccess(message: "AppLovin Interstitial showSuccess")
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.interstitialClicked(message: "AppLovin Interstitial Click")
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) { }

    func videoPlaybackBegan(in ad: ALAd) { }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) { }
}
