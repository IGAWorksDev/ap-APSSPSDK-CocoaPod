//
//  FBAudienceNetworkMediationNativeAdView.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 2023/09/15.
//

import UIKit

import APSSPSDK
import FBAudienceNetwork


@objc
public final class APSSPFBANNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var adUIView: UIView?
    @objc public var adIconImageView: FBMediaView?
    @objc public var adCoverMediaView: FBMediaView?
    @objc public var adTitleLable: UILabel?
    @objc public var adBodyLabel: UILabel?
    @objc public var adCallToActionButton: UIButton?
    @objc public var adSocialContextLabel: UILabel?
    @objc public var adSponsoredLabel: UILabel?
    @objc public var adChoicesView: FBAdChoicesView?
}


@objc
public final class APSSPFBANNativeBannerRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var adUIView: UIView?
    @objc public var adIconImageView: FBMediaView?
    @objc public var adChoicesView: FBAdChoicesView?
    @objc public var adAdvertiserNameLabel: UILabel?
    @objc public var adSponsoredLabel: UILabel?
    @objc public var adCallToActionButton: UIButton?
}


final class FBAudienceNetworkMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    private var nativeRenderer: APSSPFBANNativeAdRenderer?
    
    private var nativeBannerRenderer: APSSPFBANNativeBannerRenderer?
    
    private var nativeAd: FBNativeAd?
    
    private var nativeBannerAd: FBNativeBannerAd?
    
    private var biddingData: String
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String, biddingData: String, rootViewController: UIViewController?, render: AnyObject?, isNativeBanner: Bool?) {
        self.placementId = placementId
        self.biddingData = biddingData
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        
        guard let isNativeBanner else { return }
        if isNativeBanner {
            if let render = render as? APSSPFBANNativeBannerRenderer {
                nativeBannerRenderer = render
            }
        } else {
            if let render = render as? APSSPFBANNativeAdRenderer {
                nativeRenderer = render
            }
        }
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FBAudienceNetwork Native placementId is empty")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        if nativeBannerRenderer != nil {
            let nativeBannerAd = FBNativeBannerAd(placementID: placementId)
            self.nativeBannerAd = nativeBannerAd
            nativeBannerAd.delegate = self
            APLogger.debug("Start FaceBook NativeBanner load, placementId: \(placementId)")
            nativeBannerAd.loadAd(withBidPayload: biddingData)
        } else {
            nativeAd = FBNativeAd(placementID: placementId)
            nativeAd?.delegate = self
            APLogger.debug("Start FaceBook Native load, placementId: \(placementId)")
            nativeAd?.loadAd(withBidPayload: biddingData)
        }
    }
    
    func stop() {
        nativeAd?.unregisterView()
        nativeBannerAd?.unregisterView()
    }
    
    // MARK: - Native 렌더링
    
    private func showNativeAd() {
        guard let nativeAd, nativeAd.isAdValid, let renderer = nativeRenderer else {
            APLogger.error("FAN Native ad is not valid or renderer is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "FAN native ad invalid")
            return
        }
        
        nativeAd.unregisterView()
        
        // clickable views 수집
        var clickableViews: [UIView] = []
        if let v = renderer.adTitleLable { clickableViews.append(v) }
        if let v = renderer.adBodyLabel { clickableViews.append(v) }
        if let v = renderer.adIconImageView { clickableViews.append(v) }
        if let v = renderer.adCoverMediaView { clickableViews.append(v) }
        if let v = renderer.adSocialContextLabel { clickableViews.append(v) }
        if let v = renderer.adSponsoredLabel { clickableViews.append(v) }
        if let v = renderer.adCallToActionButton { clickableViews.append(v) }
        
        // registerView
        guard let containerView = renderer.adUIView else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "FAN adUIView is nil")
            return
        }
        nativeAd.registerView(forInteraction: containerView,
                              mediaView: renderer.adCoverMediaView ?? FBMediaView(),
                              iconView: renderer.adIconImageView,
                              viewController: rootViewController,
                              clickableViews: clickableViews)
        
        // 데이터 바인딩
        renderer.adTitleLable?.text = nativeAd.advertiserName
        renderer.adBodyLabel?.text = nativeAd.bodyText
        renderer.adSocialContextLabel?.text = nativeAd.socialContext
        renderer.adSponsoredLabel?.text = nativeAd.sponsoredTranslation
        renderer.adCallToActionButton?.setTitle(nativeAd.callToAction, for: .normal)
        if let adChoicesView = renderer.adChoicesView {
            adChoicesView.nativeAd = nativeAd
        }
        
        renderer.contentView = containerView
        delegate?.nativeLoadSuccess()
    }
    
    // MARK: - NativeBanner 렌더링
    
    private func showNativeBannerAd() {
        guard let nativeBannerAd, nativeBannerAd.isAdValid, let renderer = nativeBannerRenderer else {
            APLogger.error("FAN NativeBanner ad is not valid or renderer is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "FAN native banner ad invalid")
            return
        }
        
        nativeBannerAd.unregisterView()
        
        // 데이터 바인딩 + clickable views 수집
        var clickableViews: [UIView] = []
        if let label = renderer.adAdvertiserNameLabel {
            label.text = nativeBannerAd.advertiserName
            clickableViews.append(label)
        }
        if let label = renderer.adSponsoredLabel {
            label.text = nativeBannerAd.sponsoredTranslation
            clickableViews.append(label)
        }
        if let button = renderer.adCallToActionButton {
            if let cta = nativeBannerAd.callToAction, !cta.isEmpty {
                button.isHidden = false
                button.setTitle(cta, for: .normal)
                clickableViews.append(button)
            } else {
                button.isHidden = true
            }
        }
        
        // registerView
        guard let containerView = renderer.adUIView else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "FAN NativeBanner adUIView is nil")
            return
        }
        nativeBannerAd.registerView(forInteraction: containerView,
                                    iconView: renderer.adIconImageView ?? FBMediaView(),
                                    viewController: rootViewController,
                                    clickableViews: clickableViews)
        
        if let adChoicesView = renderer.adChoicesView {
            adChoicesView.corner = .topLeft
            adChoicesView.nativeAd = nativeBannerAd
        }
        
        renderer.contentView = containerView
        delegate?.nativeLoadSuccess()
    }
}

// MARK: - FBNativeAdDelegate
extension FBAudienceNetworkMediationNativeAdView: FBNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        APLogger.debug("FAN nativeAdDidLoad")
        self.nativeAd = nativeAd
        showNativeAd()
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        APLogger.error("FAN Native Error: \(error.localizedDescription)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        delegate?.nativeClicked(message: "FAN Native clicked")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        delegate?.nativeImpression(message: "FAN Native impression")
    }
}

// MARK: - FBNativeBannerAdDelegate
extension FBAudienceNetworkMediationNativeAdView: FBNativeBannerAdDelegate {
    func nativeBannerAdDidLoad(_ nativeBannerAd: FBNativeBannerAd) {
        APLogger.debug("FAN nativeBannerAdDidLoad")
        self.nativeBannerAd = nativeBannerAd
        showNativeBannerAd()
    }
    
    func nativeBannerAd(_ nativeBannerAd: FBNativeBannerAd, didFailWithError error: Error) {
        APLogger.error("FAN NativeBanner Error: \(error.localizedDescription)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeBannerAdDidClick(_ nativeBannerAd: FBNativeBannerAd) {
        delegate?.nativeClicked(message: "FAN NativeBanner clicked")
    }
    
    func nativeBannerAdWillLogImpression(_ nativeBannerAd: FBNativeBannerAd) {
        delegate?.nativeImpression(message: "FAN NativeBanner impression")
    }
}
