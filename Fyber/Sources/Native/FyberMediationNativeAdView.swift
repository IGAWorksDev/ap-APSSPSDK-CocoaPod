//
//  FyberMediationNativeAdView.swift
//  MediationFyber
//

import UIKit

import APSSPSDK
import IASDKCore

@objc
public final class APSSPFyberNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: UIView?
    @objc public var titleLabel: UILabel?
    @objc public var descriptionLabel: UILabel?
    @objc public var ctaButton: UIButton?
    @objc public var iconImageView: UIImageView?
}


final class FyberMediationNativeAdView: NSObject {
    
    var delegate: APSSPNativeViewAdapterDelegate?
    
    private let placementId: String
    
    private weak var rootViewController: UIViewController?
    
    private var biddingData: String?
    
    private var nativeAdSpot: IANativeAdSpot?
    
    var fyberRenderer: APSSPFyberNativeAdRenderer?
    
    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Fyber Native placementId is empty")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        // Fyber Native는 bidding only
        guard let biddingData else {
            APLogger.error("Fyber Native only provides bidding")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber adRequest is nil")
            return
        }
        
        let adRequest = IAAdRequest.build { builder in
            builder.spotID = self.placementId
            builder.timeout = 10
        }
        
        let nativeAdSpot = IANativeAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.delegate = self
        }
        
        self.nativeAdSpot = nativeAdSpot
        APLogger.debug("Start Fyber Native load, placementId: \(placementId)")
        
        nativeAdSpot.loadAd(withMarkup: biddingData) { [weak self] nativeAdAssets, error in
            guard let self else { return }
            if let error {
                APLogger.error("Fyber Native Error: \(error.localizedDescription)")
                self.delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native load error")
                return
            }
            
            guard let nativeAdAssets else {
                self.delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native ad data is nil")
                return
            }
            
            // TODO: renderer에 nativeAdAssets 바인딩 (adTitle, adDescription, callToActionText, appIcon, mediaView)
            APLogger.debug("Fyber Native Success")
            self.fyberRenderer?.contentView = self.fyberRenderer?.nativeAdView
            self.delegate?.nativeLoadSuccess()
        }
    }
    
    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}


extension FyberMediationNativeAdView: IANativeAdDelegate {
    func iaParentViewController(forAdSpot adSpot: IANativeAdSpot?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    
    func iaNativeAdDidReceiveClick(_ adSpot: IANativeAdSpot?, origin: String?) {
        delegate?.nativeClicked(message: "Fyber Native Clicked")
    }
    
    func iaNativeAdWillLogImpression(_ adSpot: IANativeAdSpot?) {
        delegate?.nativeImpression(message: "Fyber Native Impression")
    }
}
