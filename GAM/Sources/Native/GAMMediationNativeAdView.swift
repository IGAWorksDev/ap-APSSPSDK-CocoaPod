//
//  GAMMediationNativeAdView.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import GoogleMobileAds
import APSSPSDK


@objc
public final class APSSPGAMNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var gamNativeAdView: NativeAdView?
}


final class GAMMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var gamRenderer: APSSPGAMNativeAdRenderer?
    
    private var nativeAd: NativeAd!
    
    private var adLoader: AdLoader!
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        guard let render = render as? APSSPGAMNativeAdRenderer else { return }
        gamRenderer = render
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        guard let gamRenderer else {
            APLogger.error("GAMNativeAdRenderer doesn't connected")
            delegate?.nativeLoadFail(error: .delegateError, errorMessage: "delegate is nil")
            return
        }
        let multipleAdOptions = MultipleAdsAdLoaderOptions()
        adLoader = AdLoader(adUnitID: placementId,
            rootViewController: rootViewController,
            adTypes: [ .native ],
            options: [ multipleAdOptions ])

        adLoader.delegate = self
        adLoader.load(AdManagerRequest())
    }
    
    func stop() {
        nativeAd?.delegate = nil
        nativeAd = nil
        adLoader = nil
    }
    
    private func setupNativeAd() {
        guard let gamRenderer else { return }
        
        guard let nativeAdView = gamRenderer.gamNativeAdView else { return }
        
        nativeAd.delegate = self
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint.isActive = true
        }
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }
}


extension GAMMediationNativeAdView: NativeAdLoaderDelegate, NativeAdDelegate {
    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        APLogger.error("GAM Native Error: \(error.localizedDescription)")
    }
    
    public func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        delegate?.nativeLoadSuccess()
    }
    
    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        setupNativeAd()
    }
}
