//
//  AdForusNativeAdapter.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit
import APSSPSDK


final public class AdForusNativeAdapter: APSSPNativeAdapterProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var adForusNativeAdView: AdForusMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.adForusNativeAdView = AdForusMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        adForusNativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        adForusNativeAdView.delegate = self
        adForusNativeAdView.load()
    }

    public func disconnectDelegate() {
        adForusNativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        adForusNativeAdView.stop()
    }
}


extension AdForusNativeAdapter: APSSPNativeViewAdapterDelegate {
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
