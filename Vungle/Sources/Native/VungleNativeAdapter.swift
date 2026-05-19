//
//  VungleNativeAdapter.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK


final public class VungleNativeAdapter: APSSPNativeAdapterInappBiddingProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var nativeAdView: VungleMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.vunglePlacementId.rawValue] ?? ""
        self.nativeAdView = VungleMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        nativeAdView.delegate = self
    }

    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.vunglePlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.nativeAdView = VungleMediationNativeAdView(placementId: placementId, 
                                                        rootViewController: rootViewController,
                                                        render: render)
        nativeAdView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        nativeAdView.delegate = self
        nativeAdView.load()
    }

    public func disconnectDelegate() {
        nativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        nativeAdView.stop()
    }
    
    public func getBiddingToken() -> String {
        return nativeAdView.getBiddingToken()
    }
    
}


extension VungleNativeAdapter: APSSPNativeViewAdapterDelegate {
    public func nativeLoadSuccess() {
        delegate?.nativeLoadSuccess()
    }
    
    public func nativeLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.nativeLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func nativeClicked(message: String) {
        delegate?.nativeClicked(message: message)
    }
    
    public func nativeImpression(message: String) {
        delegate?.nativeImpression(message: message)
    }
}
