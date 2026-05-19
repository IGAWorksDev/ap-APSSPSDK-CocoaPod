//
//  AppLovinMediationBannerView.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK


final class AppLovinMediationBannerView: UIView {
    
    var bannerView: ALAdView!
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    weak private var rootViewController: UIViewController?
    
    private let placementId: String
    
    private let bannerType: APSSPBannerSize
    
    init(placementId: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        bannerView = ALAdView(size: ALAdSize.banner, zoneIdentifier: placementId)
        
        switch bannerType {
        case .banner320x50:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        case .banner320x100:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        case .banner300x250:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        case .bannerAdaptiveSize:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        }
        
        bannerView.autoresizingMask = AutoresizingMask.flexibleWidth
        bannerView.adLoadDelegate = self
        bannerView.adDisplayDelegate = self
        bannerView.adEventDelegate = self
        
        setupLayout()
        APLogger.debug("Start AppLovin Banner load,  UnitID: \(placementId)")
        bannerView.loadNextAd()
    }
    
    func stop() {
        bannerView?.adLoadDelegate = nil
        bannerView?.adDisplayDelegate = nil
        bannerView?.adEventDelegate = nil
        bannerView?.removeFromSuperview()
        bannerView = nil
    }
    
    func setupLayout() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
        addSubview(bannerView!)
        
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
   
}


extension AppLovinMediationBannerView: ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        APLogger.error("AppLovin Banner Error: \(APAppLovinError.init(rawValue: code) ?? .error)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "AppLovin load failed with code: \(code)")
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.bannerViewImpression(message: "AppLovin Banner Impression")
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) { }
    
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.bannerViewClicked(message: "AppLovin Banner Click")
    }
    
}

