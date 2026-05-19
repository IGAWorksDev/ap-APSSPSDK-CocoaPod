//
//  CaulyBannerAdapter.swift
//  MediationCauly
//
//  Created by Odin.송황호 on 5/23/24.
//

import UIKit

import APSSPSDK


final public class CaulyBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let caulyBannerView: CaulyMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.appCode.rawValue] ?? ""
        self.caulyBannerView = CaulyMediationBannerView(placementId: placementId, bannerType: bannerType, rootviewcontroller: rootViewController)
        self.rootViewController = rootViewController
        caulyBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        caulyBannerView.load()
    }
    
    public func disconnectDelegate() {
        caulyBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        caulyBannerView.stop()
    }
}


extension CaulyBannerAdapter: APSSPBannerAdapterDelegate {
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



