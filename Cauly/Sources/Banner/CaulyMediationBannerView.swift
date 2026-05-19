//
//  CaulyMediationBannerView.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/27/24.
//

import UIKit

import APSSPSDK
import CaulySDK


final class CaulyMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let placementId: String
    
//    private var adLoader : GFPAdLoader?
    
    private var bannerView: CaulyAdView?
    
    private var rootviewController: UIViewController?
    
    private var bannerType: APSSPBannerSize
    
    
    init(placementId: String,bannerType: APSSPBannerSize, rootviewcontroller: UIViewController?) {
        self.rootviewController = rootviewcontroller
        self.placementId = placementId
        self.bannerType = bannerType   // NAM은 오로지 이 사이즈만 제공
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
        addSubview(bannerView!)

        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func load() {
        let caulySetting = CaulyAdSetting.global();
        switch bannerType {
        case .banner320x50:
            caulySetting?.adSize = CaulyAdSize_IPhone
        case .banner320x100:
            caulySetting?.adSize = CaulyAdSize_IPhoneLarge
        case .banner300x250:
            caulySetting?.adSize = CaulyAdSize_IPhoneMediumRect
        case .bannerAdaptiveSize:
            caulySetting?.adSize = CaulyAdSize_IPhoneMediumRect
        }
        
        guard let rootviewController else {
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        bannerView = CaulyAdView.init(parentViewController: rootviewController)
        bannerView?.delegate = self                                                //  delegate 설정
        APLogger.debug("Start Cauly Banner load,  UnitID: \(placementId)")
        bannerView?.startBannerAdRequest()                                         //  배너광고 요청
    }
    
    func stop() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
    }
}


extension CaulyMediationBannerView: CaulyAdViewDelegate {
    func didReceiveAd(_ adView: CaulyAdView!, isChargeableAd: Bool) {
        setupLayout()
        adView.show(withParentViewController: rootviewController, target: self)
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func didFail(toReceiveAd adView: CaulyAdView!, errorCode: Int32, errorMsg: String!) {
        APLogger.error("Cauly Banner Error: \(errorMsg ?? "Cauly error")")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: errorMsg)
    }
}
