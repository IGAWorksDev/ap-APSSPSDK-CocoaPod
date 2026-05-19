//
//  AppLovinMaxMediationBannerView.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK
import AppLovinSDK


final class AppLovinMaxMediationBannerView: UIView {
    
    var bannerView: MAAdView!
    
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
        
        bannerView = MAAdView(adUnitIdentifier: placementId) // appKey?
        bannerView.delegate = self
        
        switch bannerType {
        case .banner320x50:
            bannerView.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.main.bounds), bannerType.height)
        case .banner320x100:
            APLogger.error("AppLovin does not support 320x100")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "AppLovin does not support 320x100")
            return
        case .banner300x250:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        case .bannerAdaptiveSize:
            bannerView.frame = CGRectMake(0, 0, bannerType.width, bannerType.height)
        }
        setupLayout()
        bannerView.setExtraParameterForKey("jC7Fp", value: "«value»")
        bannerView.loadAd()
    }
    
    func stop() {
        bannerView?.stopAutoRefresh()
        bannerView?.delegate = nil
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


extension AppLovinMaxMediationBannerView: MAAdViewAdDelegate {
    func didLoad(_ ad: MAAd) {
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        APLogger.error("AppLovinMax Banner Error: \(error.description)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.message)
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.bannerViewImpression(message: "AppLovinMax Banner Impression")
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.bannerViewClicked(message: "AppLovinMax Banner Click")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        APLogger.error("AppLovinMax Banner Error: \(error.description)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.message)
    }
    
    func didHide(_ ad: MAAd) { }
    
    func didExpand(_ ad: MAAd) { }
    
    func didCollapse(_ ad: MAAd) { }
}
