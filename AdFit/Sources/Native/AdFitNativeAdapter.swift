//
//  AdFitNativeAdapter.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 5/23/24.
//

import UIKit

import APSSPSDK


final public class AdFitNativeAdapter: APSSPNativeAdapterProtocol {
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?

    public var rootViewController: UIViewController?
    
    public var render: AnyObject?
    
    private var adfitNativeAdView: AdFitMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.clientId.rawValue] ?? ""
        self.adfitNativeAdView = AdFitMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        adfitNativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        adfitNativeAdView.delegate = self
        adfitNativeAdView.load()
    }

    public func disconnectDelegate() {
        adfitNativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        adfitNativeAdView.stop()
    }
}


extension AdFitNativeAdapter: APSSPNativeViewAdapterDelegate {
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
