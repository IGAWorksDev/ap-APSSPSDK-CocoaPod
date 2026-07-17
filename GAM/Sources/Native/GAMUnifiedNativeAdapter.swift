//
//  GAMUnifiedNativeAdapter.swift
//  MediationGAM
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


/// GAM 통합형 네이티브 광고 Adapter.
/// 실제 로드/바인딩 로직은 GAMMediationUnifiedNativeAdView에 위임합니다.
final public class GAMUnifiedNativeAdapter: APSSPUnifiedNativeAdapterProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var gamUnifiedNativeAdView: GAMMediationUnifiedNativeAdView
    
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.gamUnifiedNativeAdView = GAMMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        gamUnifiedNativeAdView.delegate = self
        gamUnifiedNativeAdView.load()
    }
    
    public func disconnectDelegate() {
        gamUnifiedNativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        gamUnifiedNativeAdView.stop()
    }
}


// MARK: - APSSPUnifiedNativeAdapterDelegate
extension GAMUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
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
