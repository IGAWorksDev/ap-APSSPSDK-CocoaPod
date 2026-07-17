//
//  FBAudienceNetworkMediationUnifiedNativeAdView.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import FBAudienceNetwork
import APSSPSDK


/// FAN 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// FBNativeAd를 로드하고, ViewBinder에 데이터를 바인딩합니다.
/// registerViewForInteraction 호출이 필수입니다.
final class FBAudienceNetworkMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private let biddingData: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAd: FBNativeAd?
    private var mediaView: FBMediaView?
    private var iconView: FBMediaView?
    
    
    init(placementId: String, biddingData: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.biddingData = biddingData
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("FBAudienceNetworkMediationUnifiedNativeAdView deinit")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FAN UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        nativeAd = FBNativeAd(placementID: placementId)
        nativeAd?.delegate = self
        nativeAd?.loadAd(withBidPayload: biddingData)
    }
    
    func stop() {
        nativeAd?.unregisterView()
        nativeAd = nil
    }
}


// MARK: - ViewBinder 바인딩
private extension FBAudienceNetworkMediationUnifiedNativeAdView {
    
    func bindToViewBinder() {
        guard let nativeAd, nativeAd.isAdValid else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN native ad invalid")
            return
        }
        
        nativeAd.unregisterView()
        
        // 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.advertiserName
        viewBinder.bodyLabel?.text = nativeAd.bodyText
        viewBinder.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)
        
        // 옵셔널 필드
        var visibleKeys = Set<String>()
        
        if let socialContext = nativeAd.socialContext, !socialContext.isEmpty {
            viewBinder.socialContextLabel?.text = socialContext
            visibleKeys.insert("socialContext")
        }
        if let sponsored = nativeAd.sponsoredTranslation, !sponsored.isEmpty {
            viewBinder.sponsoredLabel?.text = sponsored
            visibleKeys.insert("sponsored")
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // MediaView → mediaContainerView
        let coverMediaView = FBMediaView()
        mediaView = coverMediaView
        if let _ = viewBinder.mediaContainerView {
            viewBinder.insertMediaView(coverMediaView)
        }
        
        // Icon → iconImageView (FBMediaView로 대체)
        let fbIconView = FBMediaView()
        iconView = fbIconView
        if let iconImageView = viewBinder.iconImageView {
            fbIconView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.superview?.insertSubview(fbIconView, aboveSubview: iconImageView)
            NSLayoutConstraint.activate([
                fbIconView.topAnchor.constraint(equalTo: iconImageView.topAnchor),
                fbIconView.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
                fbIconView.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
                fbIconView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor)
            ])
            iconImageView.isHidden = true
        }
        
        // registerViewForInteraction (필수 — 클릭/impression 등록)
        guard let container = viewBinder.containerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN containerView is nil")
            return
        }
        
        var clickableViews: [UIView] = []
        if let v = viewBinder.titleLabel { clickableViews.append(v) }
        if let v = viewBinder.bodyLabel { clickableViews.append(v) }
        if let v = viewBinder.ctaButton { clickableViews.append(v) }
        if let v = viewBinder.socialContextLabel { clickableViews.append(v) }
        if let v = viewBinder.sponsoredLabel { clickableViews.append(v) }
        clickableViews.append(coverMediaView)
        
        nativeAd.registerView(
            forInteraction: container,
            mediaView: coverMediaView,
            iconView: fbIconView,
            viewController: rootViewController,
            clickableViews: clickableViews
        )
        
        // AdChoice 처리
        if let adChoiceContainer = viewBinder.adChoiceContainerView {
            let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
            adChoicesView.translatesAutoresizingMaskIntoConstraints = false
            adChoiceContainer.addSubview(adChoicesView)
            NSLayoutConstraint.activate([
                adChoicesView.topAnchor.constraint(equalTo: adChoiceContainer.topAnchor),
                adChoicesView.trailingAnchor.constraint(equalTo: adChoiceContainer.trailingAnchor)
            ])
            visibleKeys.insert("adChoice")
            viewBinder.hideOptionalViews(except: visibleKeys)
        }
    }
}


// MARK: - FBNativeAdDelegate
extension FBAudienceNetworkMediationUnifiedNativeAdView: FBNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        self.nativeAd = nativeAd
        bindToViewBinder()
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        APLogger.error("FAN UnifiedNative Error: \(error.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        delegate?.unifiedNativeClicked(message: "FAN UnifiedNative clicked")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        delegate?.unifiedNativeImpression(message: "FAN UnifiedNative impression")
    }
}
