//
//  MezzoMediationBannerView.swift
//  MediationMezzo
//
//  Created by Odin.송황호 on 7/2/24.
//

import UIKit

import APSSPSDK

import LibADPlus


final class MezzoMediationBannerView: UIView {
    
    var bannerView: ADMZBannerView = ADMZBannerView()
    
    weak var delegate: APSSPBannerAdapterDelegate?
    
    weak private var rootViewController: UIViewController?
    
    private let publisherCode: Int?
    
    private let mediaCode: Int?
    
    private let sectionCode: Int?
    
    private let bannerType: APSSPBannerSize
    
    
    init(publisherCode: Int?, mediaCode: Int?, sectionCode: Int?, bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        self.publisherCode = publisherCode
        self.mediaCode = mediaCode
        self.sectionCode = sectionCode
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        super.init(frame: CGRect(x: 0, y: 0, width: self.bannerType.width, height: self.bannerType.height))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        guard let publisherCode, let mediaCode, let sectionCode else {
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "MezzoMedia publisherCode or mediaCode or sectionCode is nil")
            return
        }
        switch bannerType {
        case .banner300x250, .bannerAdaptiveSize:
            APLogger.error("MezzoMedia does not support 300x250, AdaptiveSize")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "MezzoMedia does not support 300x250, AdaptiveSize")
            return
        case .banner320x50, .banner320x100:
            let model = ADMZBannerModel(withPublisherID: publisherCode,
                                        withMediaID: mediaCode,
                                        withSectionID: sectionCode,
                                        withBannerSize: .init(width: bannerType.width, height: bannerType.height),
                                        withKeywordParameter: "KeywordTargeting",
                                        withOtherParameter: "BannerAdditionalParameters",
                                        withMediaAgeLevel: .over13Age,
                                        withAppID: "appID",
                                        withAppName: "appName",
                                        withStoreURL: "appName",
                                        withSMS: true,
                                        withTel: true,
                                        withCalendar: true,
                                        withStorePicture: true,
                                        withInlineVideo: true,
                                        withBannerType:.Strip)
            bannerView.updateModel(value: model)
            
            // success
            bannerView.setSuccessHandler(value: {[weak self] code in
                self?.setupLayout()
                self?.delegate?.bannerViewSuccess(bannerView: self!)
            })

            // Fail
            bannerView.setFailHandler(value: {[weak self] code in
                let errorString = MessageManager.getResponseString(FromCode: code, fromFunction: "")
                APLogger.error("MezzoMedia Banner Error: \(errorString ?? "")")
                self?.delegate?.bannerViewFailed(bannerView: self!, error: .nextMediation, errorMessage: errorString)
            })
            
            // other
            bannerView.setOtherHandler(value: { [weak self] code in
                if code == .AdDidImpression {
                    self?.delegate?.bannerViewImpression(message: "MezzoMedia Banner Impression")
                }
                else if code == .AdClick {
                    self?.delegate?.bannerViewClicked(message: "MezzoMedia Banner Click")
                }
            })
            
            bannerView.setAPIResponseHandler(value: { dic in
                print("API DATA = \(String.init(describing: dic))")
            })
            APLogger.debug("Start MezzoMedia Banner load,  publisherCode: \(publisherCode), mediaCode: \(mediaCode), sectionCode: \(sectionCode)")
            bannerView.startBanner()
        }
    }
    
    func stop() {
        bannerView.stopBanner()
    }
    
    func setupLayout() {
        if !subviews.isEmpty {
            subviews.first!.removeFromSuperview()
        }
        addSubview(bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
   
}
