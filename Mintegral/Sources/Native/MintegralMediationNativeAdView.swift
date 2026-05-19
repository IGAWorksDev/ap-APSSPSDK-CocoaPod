//
//  MintegralMediationNativeAdView.swift
//  MediationMintegral
//
//  Created by Odin.송황호 on 7/8/24.
//

import UIKit

import APSSPSDK
import MTGSDK

@objc
public final class APSSPMintegralNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: UIView?
    @objc public var iconImageView: UIImageView?
    @objc public var appNameLabel: UILabel?
    @objc public var appDescLabel: UILabel?
    @objc public var adCallButton: UIButton?
    @objc public var adChoicesViewWithConstraint: NSLayoutConstraint?
    @objc public var adChoicesViewHeightConstraint: NSLayoutConstraint?
    
    /// MTGMediaView — UIView로 노출, 내부에서 캐스팅
    @objc public var mediaView: UIView? {
        get { _mediaView }
        set { _mediaView = newValue as? MTGMediaView }
    }
    
    /// MTGAdChoicesView — UIView로 노출, 내부에서 캐스팅
    @objc public var adChoicesView: UIView? {
        get { _adChoicesView }
        set { _adChoicesView = newValue as? MTGAdChoicesView }
    }
    
    var _mediaView: MTGMediaView?
    var _adChoicesView: MTGAdChoicesView?
}

final class MintegralMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var mintegralRenderer: APSSPMintegralNativeAdRenderer?
    
    var nativeAdLoader: MTGNativeAdManager?
    
//    var nativeAd: MAAd?
    
    var nativeAdView: UIView?
    
    private let placementId: String?
    
    private let unitID: String
    
    private let rootViewController: UIViewController?
    
    
    init(placementId: String?, unitID: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.unitID = unitID
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        guard let render = render as? APSSPMintegralNativeAdRenderer else { return }
        mintegralRenderer = render
    }

    deinit {
        APLogger.debug("MintegralMediationNativeAdView deinit")
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
        
        nativeAdLoader = MTGNativeAdManager(placementId: placementId,
                                            unitID: unitID,
                                            fbPlacementId: nil,
                                            forNumAdsRequested: 1,
                                            presenting: rootViewController)
        
        nativeAdLoader?.delegate = self
        APLogger.debug("Start Mintegral Native load,  placementId: \(placementId), UnitID: \(unitID)")
        nativeAdLoader?.loadAds()
    }
    
    func stop() {
        nativeAdLoader?.delegate = nil
        nativeAdLoader = nil
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
    }
    
    func setupData() {

    }
}


extension MintegralMediationNativeAdView: MTGNativeAdManagerDelegate, MTGMediaViewDelegate {
    func nativeAdsLoaded(_ nativeAds: [Any]?, nativeManager: MTGNativeAdManager) {
        guard let campaign = nativeAds?.first as? MTGCampaign,
              let renderer = mintegralRenderer else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Mintegral native campaign or renderer is nil")
            return
        }
        
        var clickableViews: [UIView] = []
        
        // adUIView
        if let adUIView = renderer.nativeAdView {
            clickableViews.append(adUIView)
        }
        
        // mediaView
        if let mediaView = renderer._mediaView {
            mediaView.delegate = self
            mediaView.setMediaSourceWith(campaign, unitId: unitID)
            clickableViews.append(mediaView)
        }
        
        // appNameLabel
        if let label = renderer.appNameLabel {
            label.text = campaign.appName
            clickableViews.append(label)
        }
        
        // appDescLabel
        if let label = renderer.appDescLabel {
            label.text = campaign.appDesc
            clickableViews.append(label)
        }
        
        // adCallButton
        if let button = renderer.adCallButton {
            button.setTitle(campaign.adCall, for: .normal)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .center
            clickableViews.append(button)
        }
        
        // iconImageView
        if let iconView = renderer.iconImageView {
            campaign.loadIconUrlAsync { image in
                if let image { iconView.image = image }
            }
            clickableViews.append(iconView)
        }
        
        // adChoicesView
        if let adChoicesView = renderer._adChoicesView {
            if campaign.adChoiceIconSize == .zero {
                adChoicesView.isHidden = true
            } else {
                adChoicesView.isHidden = false
                renderer.adChoicesViewWithConstraint?.constant = campaign.adChoiceIconSize.width
                renderer.adChoicesViewHeightConstraint?.constant = campaign.adChoiceIconSize.height
                clickableViews.append(adChoicesView)
            }
            adChoicesView.campaign = campaign
        }
        
        // registerView
        if let adUIView = renderer.nativeAdView {
            nativeAdLoader?.registerView(forInteraction: adUIView, withClickableViews: clickableViews, with: campaign)
        }
        
        delegate?.nativeLoadSuccess()
    }
    
    func nativeAdsFailedToLoadWithError(_ error: any Error, nativeManager: MTGNativeAdManager) {
        APLogger.error("Mintegral nativeView Error: \(error.localizedDescription)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
        
    func nativeAdDidClick(_ nativeAd: MTGCampaign, nativeManager: MTGNativeAdManager) {
        delegate?.nativeClicked(message: "Mintegral NativeView is clicked")
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, nativeManager: MTGNativeAdManager) {
        delegate?.nativeImpression(message: "Mintegral NativeView is impression")
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, mediaView: MTGMediaView) {
        delegate?.nativeClicked(message: "Mintegral NativeView is clicked")
    }
    
}

