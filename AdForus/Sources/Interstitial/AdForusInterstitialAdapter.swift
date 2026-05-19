//
//  AdForusInterstitialAdapter.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK


final public class AdForusInterstitialAdapter: APSSPInterstitialAdapterProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var adForusMediationInterstitialAd: AdForusMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        adForusMediationInterstitialAd = AdForusMediationInterstitialAd(placementId: placementId)
        self.adForusMediationInterstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.adForusMediationInterstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        adForusMediationInterstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        adForusMediationInterstitialAd?.present(from: from) { completion() }
    }
}


extension AdForusInterstitialAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() {
        delegate?.interstitialLoadSuccess()
    }
    
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func interstitialShowSuccess(message: String) {
        delegate?.interstitialShowSuccess(message: message)
    }
    
    public func interstitialShowFail(message: String) {
        delegate?.interstitialShowFail(message: message)
    }
    
    public func interstitialClicked(message: String) {
        delegate?.interstitialClicked(message: message)
    }
    
    public func interstitialClosed(message: String) {
        delegate?.interstitialClosed(message: message)
    }
}
