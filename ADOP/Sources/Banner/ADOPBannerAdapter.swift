//
//  ADOPBannerAdapter.swift
//  MediationADOP
//
//  Created by Odin.송황호 on 2023/05/16.
//

import UIKit

import APSSPSDK


final public class ADOPBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let beannerView: ADOPMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.adUnitID.rawValue] ?? ""
        self.beannerView = ADOPMediationBannerView(placementId: placementId, width: bannerType.width, height: bannerType.height, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        beannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        beannerView.load()
    }
    
    public func disconnectDelegate() {
        beannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        beannerView.stop()
    }
}


extension ADOPBannerAdapter: APSSPBannerAdapterDelegate {
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
