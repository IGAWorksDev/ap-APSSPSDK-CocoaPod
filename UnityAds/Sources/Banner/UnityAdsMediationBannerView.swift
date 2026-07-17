//
//  UnityAdsMediationBannerView.swift
//  MediationUnityAds
//
//  Created by Odin on 2026/06/04.
//

import UIKit
import APSSPSDK
import UnityAds


final class UnityAdsMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let gameID: String
    private let placementId: String
    private var bannerType: APSSPBannerSize
    private var rootViewController: UIViewController?
    private var biddingData: String?
    
    private var bannerView: UADSBannerView?
    private var unityAdsInitialization = UnityAdsInitializationAdpater()
    
    init(gameID: String, placementId: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.gameID = gameID
        self.placementId = placementId
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        self.biddingData = biddingData
        super.init(frame: CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("UnityAds Banner placementId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        if UnityAds.isInitialized() {
            loadBanner()
        } else {
            unityAdsInitialization.start(keys: ["appKey": gameID]) { [weak self] success, _ in
                if success {
                    self?.loadBanner()
                } else {
                    self?.delegate?.bannerViewFailed(bannerView: self ?? UIView(), error: .nextMediation, errorMessage: "UnityAds initialization failed")
                }
            }
        }
    }
    
    private func loadBanner() {
        let size = convertBannerSize(bannerType)
        bannerView = UADSBannerView(placementId: placementId, size: size)
        bannerView?.delegate = self
        
        APLogger.debug("Start UnityAds Banner load, placementId: \(placementId)")
        
        if let biddingData = biddingData, !biddingData.isEmpty,
           let loadOptions = UADSLoadOptions() {
            loadOptions.adMarkup = biddingData
            loadOptions.objectId = UUID().uuidString
            APLogger.debug("UnityAds Banner loading with adMarkup")
            bannerView?.load(with: loadOptions)
        } else {
            bannerView?.load()
        }
    }
    
    private func convertBannerSize(_ bannerType: APSSPBannerSize) -> CGSize {
        switch bannerType {
        case .banner320x50:
            return CGSize(width: 320, height: 50)
        case .banner320x100:
            return CGSize(width: 320, height: 100)
        case .banner300x250:
            return CGSize(width: 300, height: 250)
        case .bannerAdaptiveSize:
            return CGSize(width: 320, height: 50)
        }
    }
    
    func stop() {
        bannerView?.removeFromSuperview()
        bannerView = nil
    }
    
    func getBiddingToken() -> String {
        return UnityAds.getToken() ?? ""
    }
}


extension UnityAdsMediationBannerView: UADSBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: UADSBannerView) {
        if !subviews.isEmpty {
            subviews.forEach { $0.removeFromSuperview() }
        }
        addSubview(bannerView)
        bannerView.frame = bounds
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func bannerViewDidError(_ bannerView: UADSBannerView, error: UADSBannerError) {
        APLogger.error("UnityAds Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func bannerViewDidClick(_ bannerView: UADSBannerView) {
        delegate?.bannerViewClicked(message: "UnityAds Banner Clicked")
    }
    
    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView) {
        // Application left - no delegate callback needed
    }
}
