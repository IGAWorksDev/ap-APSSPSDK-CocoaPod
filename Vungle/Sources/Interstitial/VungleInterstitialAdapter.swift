//
//  VungleInterstitialAdapter.swift
//  MediationVungle
//

import UIKit

import APSSPSDK


final public class VungleInterstitialAdapter: APSSPInterstitialAdapterInappBiddingProtocol {

    public var rootViewController: UIViewController?
    
    public var delegate: APSSPInterstitialAdapterDelegate?
    
    private var interstitialAd: VungleMediationInterstitialAd?

    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.vunglePlacementId.rawValue] ?? ""
        interstitialAd = VungleMediationInterstitialAd(placementId: placementId)
        self.interstitialAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.vunglePlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        interstitialAd = VungleMediationInterstitialAd(placementId: placementId, biddingData: biddingData)
        self.interstitialAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        self.interstitialAd?.load()
    }
    
    public func disconnectDelegate() {
        interstitialAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        interstitialAd?.present(from: from) { completion() }
    }
    
    public func getBiddingToken() -> String {
        return interstitialAd?.getBiddingToken() ?? ""
    }
}


extension VungleInterstitialAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() { delegate?.interstitialLoadSuccess() }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.interstitialLoadFail(error: error, errorMessage: errorMessage) }
    public func interstitialShowSuccess(message: String) { delegate?.interstitialShowSuccess(message: message) }
    public func interstitialShowFail(message: String) { delegate?.interstitialShowFail(message: message) }
    public func interstitialClicked(message: String) { delegate?.interstitialClicked(message: message) }
    public func interstitialClosed(message: String) { delegate?.interstitialClosed(message: message) }
}
