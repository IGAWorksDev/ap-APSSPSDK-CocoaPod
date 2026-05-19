//
//  GAMBannerAdapter.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import APSSPSDK


final public class GAMBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let gamBannerView: GAMMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.gamBannerView = GAMMediationBannerView(placementId: placementId, width: bannerType.width, height: bannerType.height, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        gamBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        gamBannerView.load()
    }
    
    public func disconnectDelegate() {
        gamBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        gamBannerView.stop()
    }
}


extension GAMBannerAdapter: APSSPBannerAdapterDelegate {
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
