//
//  MezzoBannerAdapter.swift
//  //  MediationMezzo
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK


final public class MezzoBannerAdapter: APSSPBannerAdapterProtocol {
    
    private let bannerView: MezzoMediationBannerView
    
    weak public var delegate: APSSPBannerAdapterDelegate?
    
    weak public var rootViewController: UIViewController?
    
    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String : Any?]) {
        let publisherCode = Int(placementDic[APSSPPlacementKey.publisherCode.rawValue] ?? "")
        let mediaCode = Int(placementDic[APSSPPlacementKey.mediaCode.rawValue] ?? "")
        let sectionCode = Int(placementDic[APSSPPlacementKey.sectionCode.rawValue] ?? "")
        
        self.bannerView = MezzoMediationBannerView(publisherCode: publisherCode, 
                                                   mediaCode: mediaCode,
                                                   sectionCode: sectionCode,
                                                   bannerType: bannerType,
                                                   rootViewController: rootViewController)
        
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        bannerView.load()
    }
    
    public func disconnectDelegate() {
        bannerView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        bannerView.stop()
    }
}


extension MezzoBannerAdapter: APSSPBannerAdapterDelegate {
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
