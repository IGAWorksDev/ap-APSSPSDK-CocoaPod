//
//  AdMobUnifiedNativeAdapter.swift
//  MediationAdMob
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


/// AdMob 통합형 네이티브 광고 Adapter.
/// 실제 로드/바인딩 로직은 AdMobMediationUnifiedNativeAdView에 위임합니다.
final public class AdMobUnifiedNativeAdapter: APSSPUnifiedNativeAdapterProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var admobUnifiedNativeAdView: AdMobMediationUnifiedNativeAdView
    
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.admobUnifiedNativeAdView = AdMobMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        admobUnifiedNativeAdView.delegate = self
        admobUnifiedNativeAdView.load()
    }
    
    public func disconnectDelegate() {
        admobUnifiedNativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        admobUnifiedNativeAdView.stop()
    }
}


// MARK: - APSSPUnifiedNativeAdapterDelegate
extension AdMobUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
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
