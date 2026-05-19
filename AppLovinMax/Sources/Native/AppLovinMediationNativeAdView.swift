//
//  AppLovinMediationNativeAdView.swift
//  MediationAppLovinMax
//
//  Created by Odin.송황호 on 7/3/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK

@objc
public final class APSSPAppLovinNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: MANativeAdView?
}


final class AppLovinMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var applovinRenderer: APSSPAppLovinNativeAdRenderer?
    
    var nativeAdLoader: MANativeAdLoader?
    
    var nativeAd: MAAd?
    
    var nativeAdView: UIView?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        guard let render = render as? APSSPAppLovinNativeAdRenderer else { return }
        applovinRenderer = render
    }

    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        guard let rootViewController else {
            APLogger.error("NativeAd rootViewController is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        guard let applovinRenderer, let adView = applovinRenderer.nativeAdView else {
            APLogger.error("AppLovin nativeAdView is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "AppLovin nativeAdView is nil")
            return
        }
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: placementId)
        nativeAdLoader?.nativeAdDelegate = self
        
        nativeAdLoader?.setExtraParameterForKey("jC7Fp", value: "value")      // DynamicBiding 처리!
        APLogger.debug("Start AppLovin Native load, UnitID: \(placementId)")
        nativeAdLoader?.loadAd(into: adView)
    }
    
    func stop() {
        if let nativeAd {
            nativeAdLoader?.destroy(nativeAd)
        }
        nativeAdLoader = nil
        nativeAd = nil
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
    }
    
    func setupData() {

    }
}


extension AppLovinMediationNativeAdView: MANativeAdDelegate {
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        
        if let currentNativeAd = nativeAd {
            nativeAdLoader?.destroy(currentNativeAd)
        }
        
        nativeAd = ad
        
        guard let applovinRenderer, let adView = applovinRenderer.nativeAdView else { return }
        
        applovinRenderer.contentView = adView
        delegate?.nativeLoadSuccess()
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovin nativeView Error: \(error.description)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.description)
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        delegate?.nativeClicked(message: "AppLovin NativeView is clicked")
    }
    
}
