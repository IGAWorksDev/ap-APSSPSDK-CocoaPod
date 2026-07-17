//
//  FyberMediationUnifiedNativeAdView.swift
//  MediationFyber
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import IASDKCore
import APSSPSDK


/// Fyber Native Ad에서 뷰 상호작용 등록 시 사용하는 ViewTag
private enum FyberViewTag: Int {
    case title = 1
    case mediaView = 2
    case icon = 4
    case description = 5
    case rating = 6
    case cta = 7
    case root = 8
}


final class FyberMediationUnifiedNativeAdView: NSObject {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    private var biddingData: String?
    
    private var nativeAdSpot: IANativeAdSpot?
    private var nativeAdAssets: IANativeAdAssets?
    
    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
    }
    
    func load() {
        guard !placementId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber placementId is empty")
            return
        }
        
        // Fyber Native는 bidding only
        guard let biddingData else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native requires bidding data")
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
        
        nativeAdSpot.loadAd(withMarkup: biddingData) { [weak self] nativeAdAssets, error in
            guard let self else { return }
            if let error {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            
            guard let nativeAdAssets else {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber ad assets is nil")
                return
            }
            
            // nativeAdAssets를 strong으로 보유 (gesture target이 해제되지 않도록)
            self.nativeAdAssets = nativeAdAssets
            
            // ViewBinder 바인딩
            self.viewBinder.titleLabel?.text = nativeAdAssets.adTitle
            self.viewBinder.bodyLabel?.text = nativeAdAssets.adDescription
            self.viewBinder.ctaButton?.setTitle(nativeAdAssets.callToActionText, for: .normal)
            
            // Icon → iconImageView 위에 overlay
            if let iconView = nativeAdAssets.appIcon, let imageView = self.viewBinder.iconImageView {
                iconView.translatesAutoresizingMaskIntoConstraints = false
                imageView.superview?.insertSubview(iconView, aboveSubview: imageView)
                NSLayoutConstraint.activate([
                    iconView.topAnchor.constraint(equalTo: imageView.topAnchor),
                    iconView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                    iconView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                    iconView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
                ])
                imageView.isHidden = true
            }
            
            // MediaView → mediaContainerView에 삽입
            let mediaView = nativeAdAssets.mediaView
            mediaView.isUserInteractionEnabled = true
            self.viewBinder.insertMediaView(mediaView)
            
            self.viewBinder.hideAllOptionalViews()
            
            // containerView를 rootView로 사용
            guard let container = self.viewBinder.containerView else {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "containerView is nil")
                return
            }
            
            // ViewTag 설정
            container.tag = FyberViewTag.root.rawValue
            mediaView.tag = FyberViewTag.mediaView.rawValue
            self.viewBinder.titleLabel?.tag = FyberViewTag.title.rawValue
            self.viewBinder.bodyLabel?.tag = FyberViewTag.description.rawValue
            self.viewBinder.ctaButton?.tag = FyberViewTag.cta.rawValue
            let iconHolder = nativeAdAssets.appIcon ?? self.viewBinder.iconImageView
            iconHolder?.tag = FyberViewTag.icon.rawValue
            
            // Register Views for Interaction (클릭 이벤트 등록)
            var clickableViews: [UIView] = []
            if let title = self.viewBinder.titleLabel { clickableViews.append(title) }
            if let body = self.viewBinder.bodyLabel { clickableViews.append(body) }
            if let cta = self.viewBinder.ctaButton { clickableViews.append(cta) }
            
            nativeAdAssets.registerViewForInteraction(rootView: container,
                                                      mediaView: mediaView,
                                                      iconView: iconHolder,
                                                      clickableViews: clickableViews)
            
            self.delegate?.unifiedNativeLoadSuccess()
        }
    }
    
    func stop() {
        nativeAdSpot = nil
    }
    
    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}

extension FyberMediationUnifiedNativeAdView: IANativeAdDelegate {
    func iaParentViewController(forAdSpot adSpot: IANativeAdSpot?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    
    func iaNativeAdDidReceiveClick(_ adSpot: IANativeAdSpot?, origin: String?) {
        print("aaa")
        delegate?.unifiedNativeClicked(message: "Fyber UnifiedNative clicked")
    }
    
    func iaNativeAdWillLogImpression(_ adSpot: IANativeAdSpot?) {
        delegate?.unifiedNativeImpression(message: "Fyber UnifiedNative impression")
    }
}
