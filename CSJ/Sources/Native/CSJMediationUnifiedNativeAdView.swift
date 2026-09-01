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

// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
//
// CSJ는 `BUNativeExpressAdView`가 **완성된 광고 뷰 전체**를 렌더한다.
// title / body / icon / cta 같은 개별 에셋에 접근할 수 있는 API가 없고
// (헤더에도 render() / registerClickableRects() 정도만 공개되어 있다),
// 뷰 등록(setter) API도 없다. 따라서 매체가 만든 XIB 레이아웃을
// **구조적으로 적용할 수 없다.** 광고 뷰를 placeholder에 통째로 부착한다.
private extension CSJMediationUnifiedNativeAdView {

    func handleRenderSuccessWithContentView(_ nativeExpressAdView: BUNativeExpressAdView) {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "CSJ placeholder is nil")
            return
        }

        APLogger.debug("CSJ UnifiedNative → BUNativeExpressAdView 통째 부착 (SDK 자체 렌더 — 매체 XIB 미적용). CSJ SDK는 개별 에셋(title/body/icon/cta) 접근 API를 제공하지 않아 매체 레이아웃을 적용할 수 없습니다.")

        APSSPUnifiedNativeAssembler.attach(nativeExpressAdView, to: placeholder)
        delegate?.unifiedNativeLoadSuccess()
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
        if viewBinder.isContentViewMode {
            handleRenderSuccessWithContentView(nativeExpressAdView)
        } else {
            // 기존: CSJ는 자체 렌더링 뷰 → mediaContainerView에 삽입
            viewBinder.insertMediaView(nativeExpressAdView)
            viewBinder.hideAllOptionalViews()
            delegate?.unifiedNativeLoadSuccess()
        }
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
