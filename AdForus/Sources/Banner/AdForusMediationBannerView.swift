//
//  AdForusMediationBannerView.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK
import GoogleMobileAds


final class AdForusMediationBannerView: UIView {
    
    var bannerView: BannerView!
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    weak private var rootViewController: UIViewController?
    
    private let placementId: String
    
    private let width: Int
    
    private let height: Int
    
    init(placementId: String, width: CGFloat, height: CGFloat, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.width = Int(width)
        self.height = Int(height)
        self.rootViewController = rootViewController
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        let adSize = adSizeFor(cgSize: CGSize(width: width, height: height))
        bannerView = BannerView(adSize: adSize)
        bannerView.delegate = self
        addBannerViewToView(bannerView)

        bannerView.adUnitID = placementId
        bannerView.rootViewController = rootViewController
        APLogger.debug("Start AdForus Banner load,  UnitID: \(placementId)")
        bannerView.load(Request())
    }
    
    func stop() {
        bannerView?.delegate = nil
        bannerView?.removeFromSuperview()
        bannerView = nil
    }
    
    func addBannerViewToView(_ bannerView: BannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(bannerView)
      addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: safeAreaLayoutGuide,
                            attribute: .bottom,
                            multiplier: 1,
                            constant: 0),
         
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: self,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)])
     }
}


extension AdForusMediationBannerView: BannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        APLogger.error("AdForus Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        delegate?.bannerViewClicked(message: "AdForus Banner Click")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        delegate?.bannerViewImpression(message: "AdForus Banner Impression")
    }
}
