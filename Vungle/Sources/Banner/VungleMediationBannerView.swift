//
//  VungleMediationBannerView.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/20/24.
//

import UIKit

import APSSPSDK
import VungleAdsSDK


final class VungleMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let placementId: String
    
    private var bannerAdView: UIView = UIView()
    
    private var bannerAd: VungleBanner?
    
    private var rootviewController: UIViewController?
    
    private var bannerType: APSSPBannerSize
    
    private var biddingData: String?
    
    
    init(placementId: String, bannerType: APSSPBannerSize, rootviewcontroller: UIViewController?, biddingData: String? = nil) {
        self.rootviewController = rootviewcontroller
        self.placementId = placementId
        self.bannerType = bannerType   // NAM은 오로지 이 사이즈만 제공
        self.biddingData = biddingData
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
//        if !subviews.isEmpty {
//            subviews.first!.removeFromSuperview()
//        }
//        addSubview(bannerView!)
//
//        bannerView?.translatesAutoresizingMaskIntoConstraints = false
//        bannerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        bannerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
////        bannerView?.widthAnchor.constraint(equalToConstant: BannerSize.bannerAdaptiveSize.width).isActive = true
//        //        bannerView?.frame = CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height)
    }
    
    func load() {
        switch bannerType {
        case .banner320x50:
            bannerAd = VungleBanner(placementId: placementId, size: BannerSize.regular)
        case .banner320x100:
            APLogger.error("Vungle do not support 320x100")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "Vungle does not support 320x100")
            return
        case .banner300x250:
            bannerAd = VungleBanner(placementId: placementId, size: BannerSize.mrec)
        case .bannerAdaptiveSize:
            bannerAd = VungleBanner(placementId: placementId, size: BannerSize.mrec)
        }
        
        bannerAd?.delegate = self
        APLogger.debug("Start Vungle Banner load,  placementId: \(placementId)")
        
        
        if let biddingData {
            bannerAd?.load(biddingData)
        } else {
            bannerAd?.load()
        }
    }
    
    func stop() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


extension VungleMediationBannerView: VungleBannerDelegate {
    func bannerAdDidLoad(_ banner: VungleBanner) {
        bannerAd?.present(on: self)
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func bannerAdDidFailToLoad(_ banner: VungleBanner, withError: NSError) {
        APLogger.error("Vungle Banner Error: \(withError.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func bannerAdDidTrackImpression(_ banner: VungleBanner) {
        delegate?.bannerViewImpression(message: "Vungle Banner is Impression")
    }
    
    func bannerAdDidClick(_ banner: VungleBanner) {
        delegate?.bannerViewClicked(message: "Vungle Banner Clicked")
    }
}
