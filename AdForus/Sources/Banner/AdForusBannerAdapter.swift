//
//  AdForusBannerAdapter.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit

import APSSPSDK


final public class AdForusBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let adForusBannerView: AdForusMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.adForusBannerView = AdForusMediationBannerView(placementId: placementId, width: bannerType.width, height: bannerType.height, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        adForusBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        adForusBannerView.load()
    }
    
    public func disconnectDelegate() {
        adForusBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        adForusBannerView.stop()
    }
}


extension AdForusBannerAdapter: APSSPBannerAdapterDelegate {
    public func bannerViewSuccess(bannerView: UIView) {
        delegate?.bannerViewSuccess(bannerView: bannerView)
    }
    
    public func bannerViewFailed(bannerView: UIView, error: APSSPNetworkError, errorMessage: String?) {
        delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: errorMessage)
    }
    
    public func bannerViewClicked(message: String) {
        delegate?.bannerViewClicked(message: message)
    }
    
    public func bannerViewImpression(message: String) {
        delegate?.bannerViewImpression(message: message)
    }
}
