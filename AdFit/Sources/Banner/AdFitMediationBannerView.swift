//
//  AdFitMediationBannerView.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 6/10/24.
//

import UIKit

import APSSPSDK
import AdFitSDK


final class AdFitMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let placementId: String
    
    private var bannerView : AdFitBannerAdView?
    
    private var rootviewController: UIViewController?
    
    private var bannerType: APSSPBannerSize
    
    
    init(placementId: String, bannerType: APSSPBannerSize, rootviewcontroller: UIViewController?) {
        self.rootviewController = rootviewcontroller
        self.placementId = placementId
        self.bannerType = bannerType
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
        addSubview(bannerView!)
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bannerView?.widthAnchor.constraint(equalToConstant: APSSPBannerSize.bannerAdaptiveSize.width).isActive = true
        bannerView?.frame = CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height)
    }
    
    func load() {
        bannerView = AdFitBannerAdView(clientId: placementId, adUnitSize: bannerType.AdFitSize)
        bannerView?.rootViewController = rootviewController
        bannerView?.delegate = self
        APLogger.debug("Start AdFit Banner load,  UnitID: \(placementId)")
        bannerView?.loadAd()
    }
    
    func stop() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
    }
}


extension AdFitMediationBannerView: AdFitBannerAdViewDelegate {
    
    func adViewDidReceiveAd(_ bannerAdView: AdFitBannerAdView) {
        self.bannerView = bannerAdView
              setupLayout()
              delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        APLogger.error("AdFit Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func adViewDidClickAd(_ bannerAdView: AdFitBannerAdView) {
        delegate?.bannerViewClicked(message: "AdFit Banner Clicked")
    }
}
