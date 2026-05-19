//
//  CaulyInterstitialAdapter.swift
//  MediationCauly
//
//  Created by Odin.송황호 on 5/23/24.
//

import UIKit

import APSSPSDK


final public class CaulyInterstitialAdapter: APSSPInterstitialAdapterProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var caulyMediationInterstitialAd: CaulyMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appCode.rawValue] ?? ""
        caulyMediationInterstitialAd = CaulyMediationInterstitialAd(placementId: placementId, rootViewController: rootViewController)
        self.caulyMediationInterstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.caulyMediationInterstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        caulyMediationInterstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        caulyMediationInterstitialAd?.present(from: from) { completion() }
    }
    
}


extension CaulyInterstitialAdapter: APSSPInterstitialAdapterDelegate {
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
