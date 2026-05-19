//
//  VungleMediationNativeAdView.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK
import VungleAdsSDK

@objc
public final class APSSPVungleNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: UIView?
    @objc public var iconView: UIImageView?
    @objc public var mediaView: MediaView?
    @objc public var titleLbl: UILabel?
    @objc public var ratingLbl: UILabel?
    @objc public var sponsorLbl: UILabel?
    @objc public var privacyImage: UIImageView?
    @objc public var adTextLbl: UILabel?
    @objc public var downloadBtn: UIButton?
}


final class VungleMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var vungleRenderer: APSSPVungleNativeAdRenderer?
    
    private var nativeAd: VungleNative?

//    private var nativeAd : GFPNativeSimpleAd?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var biddingData: String?
    
    
    init(placementId: String, rootViewController: UIViewController?, render: AnyObject, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
        super.init(frame: .zero)
        
        guard let render = render as? APSSPVungleNativeAdRenderer else { return }
        vungleRenderer = render
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
        
        nativeAd = VungleNative(placementId: placementId)
        nativeAd?.delegate = self

        APLogger.debug("Start Vungle Native load,  UnitID: \(placementId)")
        
        if let biddingData {
            nativeAd?.load(biddingData)
        } else {
            nativeAd?.load()
        }
    }
    
    func stop() {
//        namRenderer?.namNativewAdView?.isHidden = true
        self.nativeAd?.unregisterView()
        self.nativeAd?.delegate = nil
        self.nativeAd = nil
    }
    
        func setupData() {
        guard let vungleRenderer else { return }
        vungleRenderer.titleLbl?.text = self.nativeAd?.title
        vungleRenderer.ratingLbl?.text = "Rating: \(nativeAd?.adStarRating ?? 0)"
        vungleRenderer.sponsorLbl?.text = self.nativeAd?.sponsoredText
        vungleRenderer.adTextLbl?.text = self.nativeAd?.bodyText
        vungleRenderer.downloadBtn?.setTitle(self.nativeAd?.callToAction, for: .normal)
        guard let nativeAdView = vungleRenderer.nativeAdView,
              let mediaView = vungleRenderer.mediaView,
              let downloadBtn = vungleRenderer.downloadBtn,
              let iconView = vungleRenderer.iconView else {
            APLogger.error("vungle renderer nativeAdView, mediaView, downloadBtn, iconView is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Vungle renderer views are nil")
            return }
        nativeAd?.adOptionsPosition = .topRight
        nativeAd?.registerViewForInteraction(view: nativeAdView,
                                             mediaView: mediaView,
                                             iconImageView: vungleRenderer.iconView,
                                             viewController: rootViewController,
                                             clickableViews: [iconView,
                                                              downloadBtn,
                                                              nativeAdView])
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


extension VungleMediationNativeAdView: VungleNativeDelegate {
    func nativeAdDidLoad(_ native: VungleNative) {
        delegate?.nativeLoadSuccess()
      }
      
      func nativeAdDidFailToLoad(_ native: VungleNative, withError: NSError) {
          APLogger.error("Vungle nativeView Error: \(withError.localizedDescription)")
          delegate?.nativeLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
      }
      
      // Ad Lifecycle Events
//      func nativeAdDidFailToPresent(_ native: VungleNative, withError: NSError) {
//          
//      }
      
      func nativeAdDidTrackImpression(_ native: VungleNative) {
          delegate?.nativeImpression(message: "Vungle NativeView is impression")
      }
      
      func nativeAdDidClick(_ native: VungleNative) {
          delegate?.nativeClicked(message: "Vungle NativeView is clicked")
      }
 }
