//
//  AdmobNativeAdapter.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/09/15.
//

import UIKit
import APSSPSDK


final public class AdMobNativeAdapter: APSSPNativeAdapterProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var admobNativeAdView: AdMobMediationNativeAdView
    

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.admobNativeAdView = AdMobMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        admobNativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        admobNativeAdView.delegate = self
        admobNativeAdView.load()
    }

    public func disconnectDelegate() {
        admobNativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        admobNativeAdView.stop()
    }
}


extension AdMobNativeAdapter: APSSPNativeViewAdapterDelegate {
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
