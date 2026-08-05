//
//  NAMMediationUnifiedNativeAdView.swift
//  MediationNAM
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import GFPSDK
import APSSPSDK


/// NAM 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// SimpleAd와 NativeAd 둘 다 요청하여, 어느 쪽이 수신되든 처리합니다.
/// - SimpleAd 수신 → GFPNativeSimpleAdView를 containerView에 통째로 삽입 (SDK 자체 렌더링)
/// - NativeAd 수신 → GFPNativeAdView를 mediaContainerView에 삽입 + ViewBinder 텍스트 바인딩
final class NAMMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var adLoader: GFPAdLoader?
    
    // NativeAd 방식
    private var nativeAd: GFPNativeAd?
    private var gfpNativeAdView: GFPNativeAdView?
    
    // SimpleAd 방식
    private var nativeSimpleAd: GFPNativeSimpleAd?
    private var simpleAdView: GFPNativeSimpleAdView?
    
    
    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("NAMMediationUnifiedNativeAdView deinit")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("NAM UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard let rootViewController else {
            APLogger.error("NAM UnifiedNative rootViewController is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        let adParam = GFPAdParam()
        adLoader = GFPAdLoader(unitID: placementId, rootViewController: rootViewController, adParam: adParam)
        
        // timeout
        let timeout = config?.namTimeoutMillis ?? 60000
        if timeout > 0 {
            adLoader?.requestTimeoutInterval = TimeInterval(timeout) / 1000.0
        }
        
        // AdChoice 위치
        let adChoicePosition: GFPAdChoicesViewPosition
        switch config?.namAdChoicePosition ?? .topRight {
        case .topLeft: adChoicePosition = .topLeftCorner
        case .topRight: adChoicePosition = .topRightCorner
        case .bottomLeft: adChoicePosition = .bottomLeftCorner
        case .bottomRight: adChoicePosition = .bottomRightCorner
        @unknown default: adChoicePosition = .topRightCorner
        }
        
        // 1. NativeSimpleAd 옵션
        let simpleSetting = GFPNativeSimpleAdRenderingSetting()
        simpleSetting.preferredAdChoicesViewPosition = adChoicePosition
        simpleSetting.adChoicesPositionInFullAdView = true
        let nativeSimpleOptions = GFPAdNativeSimpleOptions()
        nativeSimpleOptions.simpleAdRenderingSetting = simpleSetting
        adLoader?.setNativeSimpleDelegate(self, nativeSimpleOptions: nativeSimpleOptions)
        
        // 2. NativeAd 옵션
        let renderingSetting = GFPNativeAdRenderingSetting()
        renderingSetting.preferredAdChoicesViewPosition = adChoicePosition
        if config?.namEnableMediaBackgroundBlur == true {
            renderingSetting.enableMediaBackgroundBlur = true
        }
        let nativeOptions = GFPAdNativeOptions()
        nativeOptions.renderingSetting = renderingSetting
        adLoader?.setNativeDelegate(self, nativeOptions: nativeOptions)
        
        // 공통
        adLoader?.delegate = self
        
        APLogger.debug("Start NAM UnifiedNative load, UnitID: \(placementId)")
        adLoader?.loadAd()
    }
    
    func stop() {
        adLoader?.delegate = nil
        adLoader = nil
        nativeAd = nil
        nativeSimpleAd = nil
        gfpNativeAdView = nil
        simpleAdView = nil
    }
}


// MARK: - SimpleAd 처리
private extension NAMMediationUnifiedNativeAdView {
    
    func handleSimpleAd(_ nativeSimpleAd: GFPNativeSimpleAd) {
        self.nativeSimpleAd = nativeSimpleAd
        nativeSimpleAd.delegate = self
        
        guard let container = viewBinder.containerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM containerView is nil")
            return
        }
        
        // 매체가 배치한 개별 뷰들 숨김 (SimpleAd가 전부 포함하고 있으므로)
        viewBinder.titleLabel?.isHidden = true
        viewBinder.bodyLabel?.isHidden = true
        viewBinder.ctaButton?.isHidden = true
        viewBinder.iconImageView?.isHidden = true
        viewBinder.mediaContainerView?.isHidden = true
        viewBinder.hideAllOptionalViews()
        
        // GFPNativeSimpleAdView
        let adView = GFPNativeSimpleAdView()
        self.simpleAdView = adView
        
        // mediaView 세팅 + addSubview (필수)
        let mediaView = GFPMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView)
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor)
        ])
        adView.mediaView = mediaView
        
        adView.frame = container.bounds
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        adView.nativeAd = nativeSimpleAd
        container.addSubview(adView)
    }
}


// MARK: - NativeAd 처리
private extension NAMMediationUnifiedNativeAdView {

    func handleNativeAd(_ nativeAd: GFPNativeAd) {
        self.nativeAd = nativeAd

        guard let mediaContainer = viewBinder.mediaContainerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM mediaContainerView is nil")
            return
        }

        // GFPNativeAdView 생성
        let adView = GFPNativeAdView()
        self.gfpNativeAdView = adView

        // GFPMediaView 생성 및 GFPNativeAdView에 addSubview
        let mediaView = GFPMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView)
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor)
        ])
        adView.mediaView = mediaView

        // GFPNativeAdView에 뷰 연결 (NAM SDK 클릭 트래킹용)
        adView.titleLabel = viewBinder.titleLabel
        adView.bodyLabel = viewBinder.bodyLabel
        adView.advertiserLabel = viewBinder.advertiserLabel
        adView.iconView = viewBinder.iconImageView
        adView.callToActionLabel = viewBinder.ctaButton?.titleLabel

        // AdChoices 뷰 연결 (DFP 등 광고에서 자동 삽입)
        adView.adChoicesView = viewBinder.adChoiceContainerView

        // nativeAd 연결 (mediaView 렌더링 + tracking 시작)
        adView.nativeAd = nativeAd
        nativeAd.delegate = self

        // mediaContainerView에 GFPNativeAdView 삽입
        mediaContainer.subviews.forEach { $0.removeFromSuperview() }
        adView.frame = mediaContainer.bounds
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mediaContainer.addSubview(adView)

        // ViewBinder에 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.title
        viewBinder.bodyLabel?.text = nativeAd.body
        viewBinder.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)
        viewBinder.iconImageView?.image = nativeAd.iconData?.image

        // 옵셔널 필드 visible 설정
        var visibleKeys = Set<String>()

        if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
            viewBinder.advertiserLabel?.text = advertiser
            visibleKeys.insert("advertiser")
        }
        if viewBinder.adChoiceContainerView != nil {
            visibleKeys.insert("adChoice")
        }

        viewBinder.hideOptionalViews(except: visibleKeys)
    }
}


// MARK: - GFPAdLoaderDelegate
extension NAMMediationUnifiedNativeAdView: GFPAdLoaderDelegate {
    public func adLoader(_ unifiedAdLoader: GFPAdLoader!, didFailWithError error: GFPError!, responseInfo: GFPLoadResponseInfo!) {
        APLogger.error("NAM UnifiedNative Error: \(error.description)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
}


// MARK: - GFPNativeSimpleAdDelegate (SimpleAd 수신)
extension NAMMediationUnifiedNativeAdView: GFPNativeSimpleAdDelegate {
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceive nativeSimpleAd: GFPNativeSimpleAd!) {
        APLogger.debug("NAM UnifiedNative SimpleAd received")
        handleSimpleAd(nativeSimpleAd)
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func nativeSimpleAdWasClicked(_ nativeSimpleAd: GFPNativeSimpleAd) {
        delegate?.unifiedNativeClicked(message: "NAM UnifiedNative SimpleAd clicked")
    }
    
    public func nativeSimpleAdWasSeen(_ nativeSimpleAd: GFPNativeSimpleAd) {
        delegate?.unifiedNativeImpression(message: "NAM UnifiedNative SimpleAd impression")
    }
}


// MARK: - GFPNativeAdDelegate (NativeAd 수신)
extension NAMMediationUnifiedNativeAdView: GFPNativeAdDelegate {
    func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceive nativeAd: GFPNativeAd!) {
        APLogger.debug("NAM UnifiedNative NativeAd received")
        handleNativeAd(nativeAd)
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func nativeAdWasSeen(_ nativeAd: GFPNativeAd) {
        delegate?.unifiedNativeImpression(message: "NAM UnifiedNative NativeAd impression")
    }
    
    public func nativeAdWasClicked(_ nativeAd: GFPNativeAd) {
        delegate?.unifiedNativeClicked(message: "NAM UnifiedNative NativeAd clicked")
    }
}
