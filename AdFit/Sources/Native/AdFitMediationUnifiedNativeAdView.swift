//
//  AdFitMediationUnifiedNativeAdView.swift
//  MediationAdFit
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import AdFitSDK
import APSSPSDK


final class AdFitMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAdLoader: AdFitNativeAdLoader?
    private let bizboardTemplate = BizBoardTemplate()
    
    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("AdFitMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard !placementId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AdFit placementId is empty")
            return
        }
        
        nativeAdLoader = AdFitNativeAdLoader(clientId: placementId)
        nativeAdLoader?.delegate = self
        nativeAdLoader?.loadAd()
    }
    
    func stop() {
        nativeAdLoader?.delegate = nil
        nativeAdLoader = nil
    }
}

extension AdFitMediationUnifiedNativeAdView: AdFitNativeAdLoaderDelegate, AdFitNativeAdDelegate {
    
    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        let useBizBoard = config?.adFitBizBoard ?? false
        
        if useBizBoard {
            // BizBoard 템플릿 사용
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            bizboardTemplate.autoresizingMask = .flexibleWidth
            viewBinder.insertMediaView(bizboardTemplate)
        } else {
            // BizBoard 템플릿을 기본으로 사용 (통합형은 커스텀 AdFitNativeAdRenderable 뷰를 받지 않으므로)
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            bizboardTemplate.autoresizingMask = .flexibleWidth
            viewBinder.insertMediaView(bizboardTemplate)
        }
        
        viewBinder.hideAllOptionalViews()
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
        delegate?.unifiedNativeClicked(message: "AdFit UnifiedNative clicked")
    }
}
