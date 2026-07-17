//
//  CSJMediationUnifiedNativeAdView.swift
//  MediationCSJ
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import BUAdSDK
import APSSPSDK


final class CSJMediationUnifiedNativeAdView: UIView, BUCustomEventProtocol {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAdManager: BUNativeExpressAdManager?
    private var nativeAdView: BUNativeExpressAdView?
    
    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("CSJMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard !placementId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "CSJ placementId is empty")
            return
        }
        
        let slot = BUAdSlot()
        slot.id = placementId
        slot.adType = .feed
        let width = UIScreen.main.bounds.width
        nativeAdManager = BUNativeExpressAdManager(slot: slot, adSize: CGSize(width: width, height: 0))
        nativeAdManager?.delegate = self
        nativeAdManager?.loadAdData(withCount: 1)
    }
    
    func stop() {
        nativeAdManager?.delegate = nil
        nativeAdManager = nil
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
    }
}

extension CSJMediationUnifiedNativeAdView: BUNativeExpressAdViewDelegate {
    func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        guard let view = views.first else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "CSJ no ad view")
            return
        }
        nativeAdView = view
        nativeAdView?.rootViewController = rootViewController
        nativeAdView?.render()
    }
    
    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        // CSJ는 자체 렌더링 뷰 → mediaContainerView에 삽입
        viewBinder.insertMediaView(nativeExpressAdView)
        viewBinder.hideAllOptionalViews()
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error?.localizedDescription ?? "CSJ render failed")
    }
    
    func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error?.localizedDescription ?? "CSJ load failed")
    }
    
    func nativeExpressAdViewDidClick(_ nativeExpressAdView: BUNativeExpressAdView) {
        delegate?.unifiedNativeClicked(message: "CSJ UnifiedNative clicked")
    }
    
    func nativeExpressAdViewWillShow(_ nativeExpressAdView: BUNativeExpressAdView) {
        delegate?.unifiedNativeImpression(message: "CSJ UnifiedNative impression")
    }
}
