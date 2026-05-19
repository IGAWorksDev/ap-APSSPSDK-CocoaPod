//
//  AdFitInterstitialVideoAdapter.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/11/24.
//

import UIKit

import APSSPSDK


final public class AdFitInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {
   
    private var adfitMediationInterstitialVideoAd: AdFitMediationInterstitialVideoAd?
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.clientId.rawValue] ?? ""
        adfitMediationInterstitialVideoAd = AdFitMediationInterstitialVideoAd(placementId: placementId)
        self.adfitMediationInterstitialVideoAd?.delegate = self
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        adfitMediationInterstitialVideoAd?.present(from: from) { completion() }
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        self.adfitMediationInterstitialVideoAd?.load()
    }

    public func disconnectDelegate() {
        adfitMediationInterstitialVideoAd?.delegate = nil
        delegate = nil
    }
}


extension AdFitInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    
    public func interstitialVideoLoadSuccess() {
        delegate?.interstitialVideoLoadSuccess()
    }
    
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func interstitialVideoShowSuccess(message: String) {
        delegate?.interstitialVideoShowSuccess(message: message)
    }
    
    public func interstitialVideoShowFail(message: String) {
        delegate?.interstitialVideoShowFail(message: message)
    }
    
    public func interstitialVideoClicked(message: String) {
        delegate?.interstitialVideoClicked(message: message)
    }
    
    public func interstitialVideoClosed(message: String) {
        delegate?.interstitialVideoClosed(message: message)
    }
}
