//
//  AdForusInterstitialVideoAdapter.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK


final public class AdForusInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {
   
    private var adForusMediationInterstitialVideoAd: AdForusMediationInterstitialVideoAd?
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        adForusMediationInterstitialVideoAd = AdForusMediationInterstitialVideoAd(placementId: placementId)
        self.adForusMediationInterstitialVideoAd?.delegate = self
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        adForusMediationInterstitialVideoAd?.present(from: from) { completion() }
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        self.adForusMediationInterstitialVideoAd?.load()
    }

    public func disconnectDelegate() {
        adForusMediationInterstitialVideoAd?.delegate = nil
        delegate = nil
    }
}


extension AdForusInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    
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
