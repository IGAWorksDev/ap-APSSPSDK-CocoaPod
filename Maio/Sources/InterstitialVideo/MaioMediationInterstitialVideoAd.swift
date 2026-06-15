//
//  MaioMediationInterstitialVideoAd.swift
//  MediationMaio
//
//  compatible with MaioSDK v2
//

import UIKit

import APSSPSDK
import Maio


final class MaioMediationInterstitialVideoAd: NSObject {
    
    var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    private var interstitialAd: MaioInterstitial?
    
    private let zoneId: String
    
    private let rootViewController: UIViewController?
    
    
    init(zoneId: String, rootViewController: UIViewController?) {
        self.zoneId = zoneId
        self.rootViewController = rootViewController
    }
    
    func load() {
        guard !zoneId.isEmpty else {
            APLogger.error("Maio InterstitialVideo invalid zoneId")
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "Maio InterstitialVideo invalid zoneId")
            return
        }
        
        APLogger.debug("Start Maio InterstitialVideo load, zoneId: \(zoneId)")
        
        let request = MaioRequest(zoneId: zoneId, testMode: false)
        interstitialAd = MaioInterstitial.loadAd(request: request, callback: self)
    }
    
    func present(from: UIViewController, completion: @escaping () -> Void) {
        guard let interstitialAd else {
            delegate?.interstitialVideoShowFail(message: "Maio InterstitialVideo ShowFail - No Ad Loaded")
            return
        }
        interstitialAd.show(viewContext: from, callback: self)
    }
}


// MARK: - MaioInterstitialLoadCallback, MaioInterstitialShowCallback
extension MaioMediationInterstitialVideoAd: MaioInterstitialLoadCallback, MaioInterstitialShowCallback {
    
    func didLoad(_ ad: MaioInterstitial) {
        APLogger.debug("Maio InterstitialVideo didLoad")
        delegate?.interstitialVideoLoadSuccess()
    }
    
    func didFail(_ ad: MaioInterstitial, errorCode: Int) {
        APLogger.error("Maio InterstitialVideo didFail: \(errorCode)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "Maio InterstitialVideo error: \(errorCode)")
    }
    
    func didOpen(_ ad: MaioInterstitial) {
        APLogger.debug("Maio InterstitialVideo didOpen")
        delegate?.interstitialVideoShowSuccess(message: "Maio InterstitialVideo ShowSuccess")
    }
    
    func didClose(_ ad: MaioInterstitial) {
        APLogger.debug("Maio InterstitialVideo didClose")
        delegate?.interstitialVideoClosed(message: "Maio InterstitialVideo Closed")
    }
}
