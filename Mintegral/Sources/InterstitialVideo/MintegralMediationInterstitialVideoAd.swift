//
//  MintegralMediationInterstitialVideoAd.swift
//  MediationMintegral
//
//  Created by Odin.송황호 on 7/8/24.
//

import UIKit

import APSSPSDK
import MTGSDKNewInterstitial


final class MintegralMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialVideo: MTGNewInterstitialAdManager?
    
    private let placementId: String
    
    private let unitID: String
    
    init(placementId: String, unitID: String) {
        self.placementId = placementId
        self.unitID = unitID
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if interstitialVideo != nil {
            if interstitialVideo!.isAdReady() {
                interstitialVideo?.show(from: from)
            } else {
                delegate?.interstitialVideoShowFail(message: "Mintegral IntersititialVideo is not readey")
            }
            
            completion()
        } else {
            delegate?.interstitialVideoShowFail(message: "Mintegral IntersititialViedo is not load")
        }
    }
    
    func load() {
        interstitialVideo = MTGNewInterstitialAdManager(placementId: placementId, unitId: unitID, delegate: self)
        
        APLogger.debug("Start Mintegral InterstitialVideo load,  placementId: \(placementId), unitId: \(unitID)")
        interstitialVideo?.loadAd()
    }
}


extension MintegralMediationInterstitialVideoAd: MTGNewInterstitialAdDelegate {
    
    func newInterstitialAdLoadSuccess(_ adManager: MTGNewInterstitialAdManager) {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func newInterstitialAdLoadFail(_ error: any Error, adManager: MTGNewInterstitialAdManager) {
        APLogger.error("Mintegral InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func newInterstitialAdShowSuccess(_ adManager: MTGNewInterstitialAdManager) {
        delegate?.interstitialVideoShowSuccess(message: "Mintegral show success")
    }
    
    func newInterstitialAdShowFail(_ error: any Error, adManager: MTGNewInterstitialAdManager) {
        delegate?.interstitialVideoShowFail(message: "Mintegral show Fail")
    }
    
    func newInterstitialAdClicked(_ adManager: MTGNewInterstitialAdManager) {
        delegate?.interstitialVideoClicked(message: "Mintegral InterstitialVideo is Click")
    }
    
    func newInterstitialAdDidClosed(_ adManager: MTGNewInterstitialAdManager) {
        delegate?.interstitialVideoClosed(message: "Mintegral closed")
    }
}
