//
//  AdFitNativeAdRenderer.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 5/28/24.
//

import UIKit

import APSSPSDK
import AdFitSDK

@objc
public final class APSSPAdFitNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var adfitNativewAdView: UIView?
    @objc public var useBizBoardTemplate: Bool = false
}


final class AdFitMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var adfitRenderer: APSSPAdFitNativeAdRenderer?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var nativeAdLoader: AdFitNativeAdLoader?
    
    private let bizboardTemplate = BizBoardTemplate()
    
    // ReactNative 모드
    private var isReactNativeMode = false
    private weak var reactNativeContainerView: UIView?
    
    
    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        if let render = render as? APSSPAdFitNativeAdRenderer {
            adfitRenderer = render
        } else if let containerView = render as? UIView {
            // ReactNative 모드: UIView가 직접 전달됨
            isReactNativeMode = true
            reactNativeContainerView = containerView
        }
    }

    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        if isReactNativeMode {
            loadReactNative()
            return
        }
        guard let adfitRenderer else {
            APLogger.error("AdFit renderer is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "AdFit renderer is nil")
            return
        }
        if !adfitRenderer.useBizBoardTemplate {
            guard adfitRenderer.adfitNativewAdView is AdFitNativeAdRenderable else {
                APLogger.error("AdFit adfitNativewAdView is nil or not AdFitNativeAdRenderable")
                delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "AdFit nativeAdView is nil")
                return
            }
        }
        nativeAdLoader = AdFitNativeAdLoader(clientId: placementId)
        nativeAdLoader?.delegate = self
        nativeAdLoader?.loadAd()
    }
    
    private func loadReactNative() {
        guard let containerView = reactNativeContainerView else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "reactNativeContainerView is nil")
            return
        }
        containerView.subviews.forEach { $0.removeFromSuperview() }
        bizboardTemplate.frame = containerView.bounds
        containerView.addSubview(bizboardTemplate)
        
        nativeAdLoader = AdFitNativeAdLoader(clientId: placementId)
        nativeAdLoader?.delegate = self
        nativeAdLoader?.loadAd()
    }
    
    func stop() {
        nativeAdLoader?.delegate = nil
        nativeAdLoader = nil
    }
}


extension AdFitMediationNativeAdView: AdFitNativeAdLoaderDelegate, AdFitNativeAdDelegate {
    
    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        if isReactNativeMode {
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            bizboardTemplate.autoresizingMask = .flexibleWidth
            delegate?.nativeLoadSuccess()
            return
        }
        
        guard let adfitRenderer else { return }
        
        if adfitRenderer.useBizBoardTemplate {
            // BizBoard 템플릿: SDK 내부에서 생성하여 bind
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            bizboardTemplate.autoresizingMask = .flexibleWidth
            adfitRenderer.contentView = bizboardTemplate
            delegate?.nativeLoadSuccess()
        } else {
            // 커스텀 뷰: 매체가 넘긴 AdFitNativeAdRenderable conform 뷰에 bind
            guard let adfitView = adfitRenderer.adfitNativewAdView as? AdFitNativeAdRenderable else {
                APLogger.error("AdFitNativeAdRenderer type casting fail")
                delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "AdFitNativeAdRenderer type casting fail")
                return
            }
            nativeAd.bind(adfitView as! UIView)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            adfitRenderer.contentView = adfitRenderer.adfitNativewAdView
            delegate?.nativeLoadSuccess()
        }
    }
    
    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        APLogger.error("AdFit Native Error: \(error.localizedDescription)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
 
    func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
        delegate?.nativeClicked(message: "AdFit Native clicked")
    }
}
