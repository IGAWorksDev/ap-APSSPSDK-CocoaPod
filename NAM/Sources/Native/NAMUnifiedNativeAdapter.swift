//
//  NAMUnifiedNativeAdapter.swift
//  MediationNAM
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


final public class NAMUnifiedNativeAdapter: APSSPUnifiedNativeAdapterProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var mediationView: NAMMediationUnifiedNativeAdView
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.namUnitId.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = NAMMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config
        )
    }
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        mediationView.delegate = self
        mediationView.load()
    }
    
    public func disconnectDelegate() { mediationView.delegate = nil; delegate = nil }
    public func stop() { mediationView.stop() }
}

extension NAMUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
    public func unifiedNativeLoadSuccess() { delegate?.unifiedNativeLoadSuccess() }
    public func unifiedNativeLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.unifiedNativeLoadFail(error: error, errorMessage: errorMessage) }
    public func unifiedNativeClicked(message: String) { delegate?.unifiedNativeClicked(message: message) }
    public func unifiedNativeImpression(message: String) { delegate?.unifiedNativeImpression(message: message) }
}
