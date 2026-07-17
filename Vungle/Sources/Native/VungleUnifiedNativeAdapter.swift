//
//  VungleUnifiedNativeAdapter.swift
//  MediationVungle
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


/// Vungle 통합형 네이티브 광고 Adapter.
/// InApp Bidding 지원을 위해 APSSPUnifiedNativeAdapterInAppBiddingProtocol을 conform합니다.
/// 실제 로드/바인딩 로직은 VungleMediationUnifiedNativeAdView에 위임합니다.
final public class VungleUnifiedNativeAdapter: APSSPUnifiedNativeAdapterInAppBiddingProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var vungleUnifiedNativeAdView: VungleMediationUnifiedNativeAdView
    
    
    // MARK: - Waterfall 초기화
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.vunglePlacementId.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.vungleUnifiedNativeAdView = VungleMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config,
            biddingData: nil
        )
    }
    
    
    // MARK: - InApp Bidding 초기화
    
    public required init(inappBiddingPlacementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = inappBiddingPlacementDic[APSSPBiddingKey.vunglePlacementId.rawValue] ?? ""
        let biddingData = inappBiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue]
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.vungleUnifiedNativeAdView = VungleMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config,
            biddingData: biddingData
        )
    }
    
    
    // MARK: - APSSPUnifiedNativeAdapterProtocol
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        vungleUnifiedNativeAdView.delegate = self
        vungleUnifiedNativeAdView.load()
    }
    
    public func disconnectDelegate() {
        vungleUnifiedNativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        vungleUnifiedNativeAdView.stop()
    }
    
    
    // MARK: - APSSPUnifiedNativeAdapterInAppBiddingProtocol
    
    public func getBiddingToken() -> String {
        return vungleUnifiedNativeAdView.getBiddingToken()
    }
}


// MARK: - APSSPUnifiedNativeAdapterDelegate
extension VungleUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
    public func unifiedNativeLoadSuccess() {
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func unifiedNativeLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.unifiedNativeLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func unifiedNativeClicked(message: String) {
        delegate?.unifiedNativeClicked(message: message)
    }
    
    public func unifiedNativeImpression(message: String) {
        delegate?.unifiedNativeImpression(message: message)
    }
}
