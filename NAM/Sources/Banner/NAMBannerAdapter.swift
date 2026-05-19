//
//  NAMBannerAdapter.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/23/24.
//

import UIKit

import APSSPSDK


final public class NAMBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let namBannerView: NAMMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
//        let placementId = placementDic.first?.value ?? ""
        let publisherCode = placementDic[APSSPPlacementKey.namPublisherCode.rawValue] ?? ""
        let unitID = placementDic[APSSPPlacementKey.namUnitId.rawValue] ?? ""
        
        self.namBannerView = NAMMediationBannerView(publisherCode: publisherCode, unitID: unitID, bannerType: bannerType, rootviewcontroller: rootViewController)
        self.rootViewController = rootViewController
        namBannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        namBannerView.load()
    }
    
    public func disconnectDelegate() {
        namBannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        namBannerView.stop()
    }
}


extension NAMBannerAdapter: APSSPBannerAdapterDelegate {
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



