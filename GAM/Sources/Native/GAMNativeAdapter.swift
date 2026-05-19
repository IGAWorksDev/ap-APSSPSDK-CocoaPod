//
//  GAMNativeAdapter.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit
import APSSPSDK


final public class GAMNativeAdapter: APSSPNativeAdapterProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var gamNativeAdView: GAMMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.gamNativeAdView = GAMMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        gamNativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        gamNativeAdView.delegate = self
        gamNativeAdView.load()
    }

    public func disconnectDelegate() {
        gamNativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        gamNativeAdView.stop()
    }
}


extension GAMNativeAdapter: APSSPNativeViewAdapterDelegate {
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
