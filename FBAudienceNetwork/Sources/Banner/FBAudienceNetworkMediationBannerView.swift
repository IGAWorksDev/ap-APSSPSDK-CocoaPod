//
//  FBAudienceNetworkMediationBannerView.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 6/18/24.
//

import UIKit

import APSSPSDK
import FBAudienceNetwork


final class FBAudienceNetworkMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let placementId: String
    
    private var bannerView: FBAdView?
    
    private var rootviewController: UIViewController?
    
    private var bannerType: APSSPBannerSize
    
    private var biddingData: String
    
    
    init(placementId: String,bannerType: APSSPBannerSize, biddingData: String, rootviewcontroller: UIViewController?) {
        self.rootviewController = rootviewcontroller
        self.placementId = placementId
        self.bannerType = bannerType
        self.biddingData = biddingData
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        guard let adView = bannerView, adView.isAdValid else {
          return
        }
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
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FBAudienceNetwork Banner placementId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        switch bannerType {
        case .banner320x50:
            bannerView = FBAdView(placementID: placementId, adSize: kFBAdSizeHeight50Banner, rootViewController: rootviewController)
            bannerView?.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        case .banner320x100:
            bannerView = FBAdView(placementID: placementId, adSize: kFBAdSizeHeight90Banner, rootViewController: rootviewController)
            bannerView?.frame = CGRect(x: 0, y: 0, width: 320, height: 90)
        case .banner300x250:
            bannerView = FBAdView(placementID: placementId, adSize: kFBAdSizeHeight250Rectangle, rootViewController: rootviewController)
            bannerView?.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
        case .bannerAdaptiveSize:
            bannerView = FBAdView(placementID: placementId, adSize: kFBAdSizeHeight250Rectangle, rootViewController: rootviewController)
            bannerView?.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
        }
        bannerView?.delegate = self
        APLogger.debug("Start FBAudienceNetwork Banner load,  placementId: \(placementId)")
        bannerView?.loadAd()
//        bannerView?.loadAd(withBidPayload: biddingData)
    }
    
    func stop() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
    }
}

extension FBAudienceNetworkMediationBannerView: FBAdViewDelegate {
    func adViewDidClick(_ adView: FBAdView) {
        delegate?.bannerViewClicked(message: "FBAudienceNetwork Banner Clicked")
        print("Ad was clicked.")
    }

    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
    }

    func adViewWillLogImpression(_ adView: FBAdView) {
        delegate?.bannerViewImpression(message: "FBAudienceNetwork Banner Impression")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        APLogger.error("FBAudienceNetwork Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func adViewDidLoad(_ adView: FBAdView) {
        setupLayout()
        delegate?.bannerViewSuccess(bannerView: self)
    }
}
