//
//  MaioInterstitialVideoAdapter.swift
//  MediationMaio
//
//  compatible with MaioSDK v2
//

import UIKit

import APSSPSDK


final public class MaioInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {
    
    private var maioMediationInterstitialVideoAd: MaioMediationInterstitialVideoAd?
    
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let zoneId = placementDic[APSSPPlacementKey.maioZoneId.rawValue] ?? ""
        self.rootViewController = rootViewController
        maioMediationInterstitialVideoAd = MaioMediationInterstitialVideoAd(zoneId: zoneId, rootViewController: rootViewController)
        maioMediationInterstitialVideoAd?.delegate = self
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        maioMediationInterstitialVideoAd?.present(from: from) { completion() }
    }
    
    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        maioMediationInterstitialVideoAd?.load()
    }
    
    public func disconnectDelegate() {
        maioMediationInterstitialVideoAd?.delegate = nil
        delegate = nil
    }
}


extension MaioInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    
    public func interstitialVideoLoadSuccess() {
        delegate?.interstitialVideoLoadSuccess()
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
