//
//  AppLovinMaxUnifiedNativeAdapter.swift
//  MediationAppLovinMax
//
//  Created by Kiro on 2026/07/06.
//

import UIKit
import APSSPSDK


/// AppLovin MAX 통합형 네이티브 광고 Adapter.
/// 실제 로드/바인딩 로직은 AppLovinMaxMediationUnifiedNativeAdView에 위임합니다.
final public class AppLovinMaxUnifiedNativeAdapter: APSSPUnifiedNativeAdapterProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var unifiedNativeAdView: AppLovinMaxMediationUnifiedNativeAdView
    
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appLovinMaxUnitId.rawValue] ?? ""
        let price = placementDic[APSSPPlacementKey.price.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.unifiedNativeAdView = AppLovinMaxMediationUnifiedNativeAdView(
            placementId: placementId,
            price: price,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        unifiedNativeAdView.delegate = self
        unifiedNativeAdView.load()
    }
    
    public func disconnectDelegate() {
        unifiedNativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        unifiedNativeAdView.stop()
    }
}


// MARK: - APSSPUnifiedNativeAdapterDelegate
extension AppLovinMaxUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
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
