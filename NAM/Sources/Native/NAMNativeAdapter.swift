//
//  NAMNativeAdapter.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/23/24.
//

import UIKit

import APSSPSDK


final public class NAMNativeAdapter: APSSPNativeAdapterProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var namNativeAdView: NAMMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let unitID = placementDic[APSSPPlacementKey.namUnitId.rawValue] ?? ""
        self.namNativeAdView = NAMMediationNativeAdView(placementId: unitID, rootViewController: rootViewController, render: render)
        namNativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        namNativeAdView.delegate = self
        namNativeAdView.load()
    }

    public func disconnectDelegate() {
        namNativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        namNativeAdView.stop()
    }
}


extension NAMNativeAdapter: APSSPNativeViewAdapterDelegate {
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
