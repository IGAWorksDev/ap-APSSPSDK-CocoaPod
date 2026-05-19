//
//  MintegralMediationBannerView.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK
import MTGSDKBanner


final class MintegralMediationBannerView: UIView {
    
    var bannerView: MTGBannerAdView!
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    weak private var rootViewController: UIViewController?
    
    private let placementId: String?
    
    private let unitID: String
    
    private let bannerType: APSSPBannerSize
    
    init(placementId: String?, unitID: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.unitID = unitID
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
        
        guard let rootViewController else {
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        switch bannerType {
        case .banner320x50:
            bannerView = MTGBannerAdView(bannerAdViewWith: .standardBannerType320x50, placementId: placementId, unitId: unitID, rootViewController: rootViewController)
        case .banner320x100:
            bannerView = MTGBannerAdView(bannerAdViewWith: .largeBannerType320x90, placementId: placementId, unitId: unitID, rootViewController: rootViewController)
        case .banner300x250:
            bannerView = MTGBannerAdView(bannerAdViewWith: .mediumRectangularBanner300x250, placementId: placementId, unitId: unitID, rootViewController: rootViewController)
        case .bannerAdaptiveSize:
            bannerView = MTGBannerAdView(bannerAdViewWith: .mediumRectangularBanner300x250, placementId: placementId, unitId: unitID, rootViewController: rootViewController)
        }
        
        setupLayout()
        
        // waterfall
        bannerView.delegate = self
        APLogger.debug("Start Mintegral Banner load,  placementId: \(placementId), unitId: \(unitID)")
        bannerView.loadBannerAd()
        
        // header bidding
//        bannerView.loadBannerAd(withBidToken: "bidToken")
    }
    
    func stop() {
        bannerView?.delegate = nil
        bannerView?.destroy()
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

extension MintegralMediationBannerView: MTGBannerAdViewDelegate {
    func adViewLoadSuccess(_ adView: MTGBannerAdView!) {
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func adViewLoadFailedWithError(_ error: (any Error)!, adView: MTGBannerAdView!) {
        APLogger.error("Mintegral Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error?.localizedDescription)
    }
    
    func adViewWillLogImpression(_ adView: MTGBannerAdView!) {
        delegate?.bannerViewImpression(message: "Mintegral Banner Impression")
    }
    
    func adViewDidClicked(_ adView: MTGBannerAdView!) {
        delegate?.bannerViewClicked(message: "Mintegral Banner Click")
    }
    
    func adViewWillLeaveApplication(_ adView: MTGBannerAdView!) { }
    
    func adViewWillOpenFullScreen(_ adView: MTGBannerAdView!) { }
    
    func adViewCloseFullScreen(_ adView: MTGBannerAdView!) { }
    
    func adViewClosed(_ adView: MTGBannerAdView!) { }
}
