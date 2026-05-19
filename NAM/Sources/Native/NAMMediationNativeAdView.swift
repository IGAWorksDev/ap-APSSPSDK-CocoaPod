//
//  NAMMediationNativeAdView.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/28/24.
//

import UIKit

import APSSPSDK
import GFPSDK


@objc
public final class APSSPNAMNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    // Simple Native
    @objc public var namNativeSimpleAdView: GFPNativeSimpleAdView?
    // 일반 Native
    @objc public var namNativeAdView: GFPNativeAdView?
    // 공통
    @objc public var namDedupeManager: GFPAdDedupeManager?
    @objc public var GFPNativeSetting: GFPNativeAdRenderingSetting?
    @objc public var GFPNativeSimpleSetting: GFPNativeSimpleAdRenderingSetting?
    @objc public var timeOut: TimeInterval = 0
    @objc public var backgroundBlur: Bool = false
}


final class NAMMediationNativeAdView: UIView {
    
    weak var delegate: APSSPNativeViewAdapterDelegate?
    
    var namRenderer: APSSPNAMNativeAdRenderer?
    
    private var adLoader: GFPAdLoader?
    private var nativeSimpleAd: GFPNativeSimpleAd?
    private var nativeAd: GFPNativeAd?
    
    private let placementId: String
    private let rootViewController: UIViewController?
    
    // ReactNative 모드
    private var isReactNativeMode = false
    private weak var reactNativeContainerView: UIView?
    private var reactNativeSimpleAdView: GFPNativeSimpleAdView?
    
    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        
        if let render = render as? APSSPNAMNativeAdRenderer {
            namRenderer = render
        } else if let containerView = render as? UIView {
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
        let adParam = GFPAdParam()
        
        guard let rootViewController else {
            APLogger.error("NativeAd rootViewController is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        if isReactNativeMode {
            loadReactNative(rootViewController: rootViewController, adParam: adParam)
            return
        }
        
        guard let namRenderer else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "NAM nativeAdView is nil")
            return
        }
        
        self.adLoader = GFPAdLoader(unitID: placementId, rootViewController: rootViewController, adParam: adParam)
        
        // timeOut
        if namRenderer.timeOut > 0 {
            adLoader?.requestTimeoutInterval = namRenderer.timeOut
        }
        
        // Native Simple 설정
        var simpleSetting = namRenderer.GFPNativeSimpleSetting
        if simpleSetting == nil {
            simpleSetting = GFPNativeSimpleAdRenderingSetting()
            simpleSetting?.preferredAdChoicesViewPosition = .topRightCorner
        }
        simpleSetting?.adChoicesPositionInFullAdView = true
        let nativeSimpleOptions = GFPAdNativeSimpleOptions()
        nativeSimpleOptions.simpleAdRenderingSetting = simpleSetting
        adLoader?.setNativeSimpleDelegate(self, nativeSimpleOptions: nativeSimpleOptions)
        
        // Native 일반형 설정
        var setting = namRenderer.GFPNativeSetting
        if setting == nil {
            setting = GFPNativeAdRenderingSetting()
            setting?.preferredAdChoicesViewPosition = .topRightCorner
        }
        if namRenderer.backgroundBlur {
            setting?.enableMediaBackgroundBlur = true
        }
        let nativeOptions = GFPAdNativeOptions()
        nativeOptions.renderingSetting = setting
        let videoOption = GFPVideoOptions(playPolicy: .autoPlay, viewType: .landing, useCustomControlView: true)
        nativeOptions.videoOptions = videoOption
        adLoader?.setNativeDelegate(self, nativeOptions: nativeOptions)
        
        adLoader?.delegate = self
        
        APLogger.debug("Start NAM Native load, UnitID: \(placementId)")
        
        // dedupeManager
        if let dedupeManager = namRenderer.namDedupeManager {
            dedupeManager.loadAd(with: adLoader!)
        } else {
            adLoader?.loadAd()
        }
    }
    
    func stop() {
        adLoader?.delegate = nil
        adLoader = nil
        nativeSimpleAd = nil
        nativeAd = nil
    }
    
    private func loadReactNative(rootViewController: UIViewController, adParam: GFPAdParam) {
        self.adLoader = GFPAdLoader(unitID: placementId, rootViewController: rootViewController, adParam: adParam)
        
        let simpleSetting = GFPNativeSimpleAdRenderingSetting()
        simpleSetting.preferredAdChoicesViewPosition = .topRightCorner
        simpleSetting.adChoicesPositionInFullAdView = true
        let nativeSimpleOptions = GFPAdNativeSimpleOptions()
        nativeSimpleOptions.simpleAdRenderingSetting = simpleSetting
        adLoader?.setNativeSimpleDelegate(self, nativeSimpleOptions: nativeSimpleOptions)
        
        adLoader?.delegate = self
        
        APLogger.debug("Start NAM ReactNative load, UnitID: \(placementId)")
        adLoader?.loadAd()
    }
}


// MARK: - GFPAdLoaderDelegate + GFPNativeSimpleAdDelegate
extension NAMMediationNativeAdView: GFPAdLoaderDelegate, GFPNativeSimpleAdDelegate {
 
    // Simple Native 수신
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceive nativeSimpleAd: GFPNativeSimpleAd!) {
        // ReactNative 모드
        if isReactNativeMode {
            guard let containerView = reactNativeContainerView else {
                delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "NAM native ad data is nil")
                return
            }
            containerView.subviews.forEach { $0.removeFromSuperview() }
            
            let simpleAdView = GFPNativeSimpleAdView()
            simpleAdView.frame = containerView.bounds
            nativeSimpleAd.delegate = self
            self.nativeSimpleAd = nativeSimpleAd
            simpleAdView.nativeAd = nativeSimpleAd
            containerView.addSubview(simpleAdView)
            reactNativeSimpleAdView = simpleAdView
            
            delegate?.nativeLoadSuccess()
            return
        }
        
        guard let namRenderer else { return }
        
        guard let simpleAdView = namRenderer.namNativeSimpleAdView else {
            APLogger.error("NAM NativeSimpleAdView is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "NAM native simple ad is nil")
            return
        }
        
        nativeSimpleAd.delegate = self
        self.nativeSimpleAd = nativeSimpleAd
        simpleAdView.nativeAd = nativeSimpleAd
        
        namRenderer.contentView = simpleAdView
        
        delegate?.nativeLoadSuccess()
    }
    
    public func adLoader(_ unifiedAdLoader: GFPAdLoader!, didFailWithError error: GFPError!, responseInfo: GFPLoadResponseInfo!) {
        APLogger.error("NAM Native Error: \(error.description)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    public func nativeSimpleAdWasClicked(_ nativeSimpleAd: GFPNativeSimpleAd) {
        delegate?.nativeClicked(message: "NAM Native Simple Clicked")
    }
    
    public func nativeSimpleAdWasSeen(_ nativeSimpleAd: GFPNativeSimpleAd) {
        delegate?.nativeImpression(message: "NAM Native Simple Impression")
    }
}


// MARK: - GFPNativeAdDelegate (일반 Native)
extension NAMMediationNativeAdView: GFPNativeAdDelegate {
    
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceive nativeAd: GFPNativeAd!) {
        guard let namRenderer else { return }
        
        guard let nativeAdView = namRenderer.namNativeAdView else {
            APLogger.error("NAM NativeAdView is nil, fallback to simple")
            return
        }
        
        // bodyLabel, mediaView 필수 체크
        if nativeAdView.bodyLabel == nil || nativeAdView.mediaView == nil {
            APLogger.error("NAM Normal Native mediaView and bodyLabel is not connected")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "NAM native ad rendering failed")
            return
        }
        
        self.nativeAd = nativeAd
        nativeAd.delegate = self
        
        // 텍스트 바인딩
        nativeAdView.callToActionLabel?.text = nativeAd.callToAction
        nativeAdView.advertiserLabel?.text = nativeAd.advertiser
        nativeAdView.bodyLabel?.text = nativeAd.body
        nativeAdView.titleLabel?.text = nativeAd.title
        nativeAdView.adBadgeLabel?.text = nativeAd.badge
        
        // 광고 세팅 → mediaView 렌더링 + 뷰 트래킹 시작
        nativeAdView.nativeAd = nativeAd
        
        namRenderer.contentView = nativeAdView
        
        delegate?.nativeLoadSuccess()
    }
    
    func nativeAd(_ nativeAd: GFPNativeAd, didFailWithError error: GFPError) {
        APLogger.error("NAM Normal Native rendering error: \(error)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdWasClicked(_ nativeAd: GFPNativeAd) {
        delegate?.nativeClicked(message: "NAM Native Clicked")
    }
    
    func nativeAdWasSeen(_ nativeAd: GFPNativeAd) {
        delegate?.nativeImpression(message: "NAM Native Impression")
    }
    
    func nativeAdWasMuted(_ nativeAd: GFPNativeAd) {
        APLogger.debug("NAM Native was muted (hidden)")
    }
}
