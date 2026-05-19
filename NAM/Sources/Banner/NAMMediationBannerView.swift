//
//  NAMMediationBannerView.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/27/24.
//

import UIKit

import APSSPSDK
import GFPSDK


final class NAMMediationBannerView: UIView {
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    private let publisherCode: String
    
    private let unitID: String
    
    private var adLoader : GFPAdLoader?
    
    private var bannerView : GFPBannerView?
    
    private var rootviewController: UIViewController?
    
    private var bannerType: APSSPBannerSize
    
    
    init(publisherCode: String, unitID: String, bannerType: APSSPBannerSize, rootviewcontroller: UIViewController?) {
        self.rootviewController = rootviewcontroller
        self.publisherCode = publisherCode
        self.bannerType = bannerType
        self.unitID = unitID
        self.bannerType = .bannerAdaptiveSize   // NAM은 오로지 이 사이즈만 제공
        super.init(frame: .zero)
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
//        frame = CGRect(x: 0, y: 0, width: bannerView?.frame.size.width, height: bannerView?.frame.height)
        addSubview(bannerView!)
        
//        frame.size.width = bannerType.width
//        frame.size.height = bannerType.height
        self.bannerView?.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView?.widthAnchor.constraint(equalToConstant: bannerType.width).isActive = true
        
        frame.size.width = (bannerView?.frame.size.width)!
        frame.size.height = (bannerView?.frame.size.height)!
        
//        let frame = CGRect(x:0 , y: 0, width: bannerType.width, height: bannerType.height)
//        self.bannerView?.frame = frame
        
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
//        bannerView?.widthAnchor.constraint(equalToConstant: BannerSize.bannerAdaptiveSize.width).isActive = true
//        bannerView?.frame = CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height)
    }
    
    func load() {
        let adParam = GFPAdParam()
//        adParam.yearOfBirth = 1990
//        adParam.gender = .male
        guard let rootviewController else {
            APLogger.error("rootViewController is nil")
            delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        self.adLoader = GFPAdLoader(unitID: unitID, rootViewController: rootviewController, adParam: adParam) // IOS_nw_banner-N345765840
        
        let bannerOption = GFPAdBannerOptions()
        bannerOption.layoutType = .fluidWidth
//        bannerOption.layoutType = GFPBannerViewLayoutType(rawValue: 0)!
        
        self.adLoader?.setBannerDelegate(self, bannerOptions: bannerOption)
//        let displayAgent = GFPRenderDisplayAgent(type: .displayAgentTypeNativeSafari)
//        GFPAdManager.adConfiguration().displayAgent = displayAgent
            
        self.adLoader?.delegate = self
        APLogger.debug("Start NAM Banner load, publisherCode: \(publisherCode), UnitID: \(unitID)")
        self.adLoader?.loadAd()
    }
    
    func stop() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
    }
}


extension NAMMediationBannerView: GFPAdLoaderDelegate, GFPBannerViewDelegate, GFPNativeSimpleAdDelegate {
    
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceiveBannerAd bannerView: GFPBannerView!) {
        self.bannerView = bannerView
        setupLayout()
        delegate?.bannerViewSuccess(bannerView: self)
    }
    
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didFailWithError error: GFPError!, responseInfo: GFPLoadResponseInfo!) {
        APLogger.error("NAM Banner Error: \(error.description)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error?.description)
    }
    
    func bannerShouldUnload(_ bannerView: GFPBannerView) {
    }
    
    func bannerAdWasSeen(_ bannerView: GFPBannerView) {
        delegate?.bannerViewImpression(message: "NAM Banner is Impression")
    }
    
    func bannerAdWasMuted(_ bannerView: GFPBannerView) {
    }
    
    func bannerAdWasClicked(_ bannerView: GFPBannerView) {
        delegate?.bannerViewClicked(message: "NAM Banner Clicked")
    }
}
