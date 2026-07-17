//
//  AdForusUnifiedNativeAdapter.swift
//  MediationAdForus
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


/// AdForus 통합형 네이티브 광고 Adapter.
/// 실제 로드/바인딩 로직은 AdForusMediationUnifiedNativeAdView에 위임합니다.
final public class AdForusUnifiedNativeAdapter: APSSPUnifiedNativeAdapterProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var adForusUnifiedNativeAdView: AdForusMediationUnifiedNativeAdView
    
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.adForusUnifiedNativeAdView = AdForusMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        adForusUnifiedNativeAdView.delegate = self
        adForusUnifiedNativeAdView.load()
    }
    
    public func disconnectDelegate() {
        adForusUnifiedNativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        adForusUnifiedNativeAdView.stop()
    }
}


// MARK: - APSSPUnifiedNativeAdapterDelegate
extension AdForusUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
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
