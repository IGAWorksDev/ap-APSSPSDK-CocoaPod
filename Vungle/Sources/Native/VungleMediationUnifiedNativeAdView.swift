//
//  VungleMediationUnifiedNativeAdView.swift
//  MediationVungle
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK
import VungleAdsSDK


/// Vungle 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// VungleNative로 광고를 로드하고, ViewBinder에 데이터를 바인딩합니다.
final class VungleMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    private var biddingData: String?
    
    private var nativeAd: VungleNative?
    
    /// VungleMediaView — mediaContainerView에 삽입.
    private var vungleMediaView: MediaView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?


    init(placementId: String,
         rootViewController: UIViewController?,
         viewBinder: APSSPMediationViewBinder,
         config: APSSPNativeAdConfig?,
         biddingData: String?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("VungleMediationUnifiedNativeAdView deinit")
    }
    
    
    // MARK: - Public
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Vungle UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard rootViewController != nil else {
            APLogger.error("Vungle UnifiedNative rootViewController is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        nativeAd = VungleNative(placementId: placementId)
        nativeAd?.delegate = self
        
        APLogger.debug("Start Vungle UnifiedNative load, PlacementID: \(placementId)")
        
        if let biddingData, !biddingData.isEmpty {
            nativeAd?.load(biddingData)
        } else {
            nativeAd?.load()
        }
    }
    
    func stop() {
        let registeredView: UIView? = contentView ?? viewBinder.containerView
        if nativeAd != nil, registeredView?.window != nil {
            nativeAd?.unregisterView()
        }
        vungleMediaView?.delegate = nil
        vungleMediaView = nil
        nativeAd?.delegate = nil
        nativeAd = nil
        contentView?.removeFromSuperview()
        contentView = nil
    }
    
    func getBiddingToken() -> String {
        return VungleAds.getBiddingToken()
    }
}


// MARK: - 공통 옵션
private extension VungleMediationUnifiedNativeAdView {

    /// `config.privacyIconPosition` → Vungle `NativeAdOptionsPosition` 매핑.
    var adOptionsPosition: NativeAdOptionsPosition {
        switch config?.privacyIconPosition ?? .topRight {
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        @unknown default: return .topRight
        }
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension VungleMediationUnifiedNativeAdView {

    /// 매체가 만든 화면(`APSSPUnifiedNativeAdView`)을 플레이스홀더에 부착하고,
    /// 그 화면 자신을 register root로 넘긴다.
    /// Vungle은 컨테이너 클래스가 없으므로 clickableViews가 root의 자손이기만 하면 된다.
    /// - Returns: 조립 성공 여부. `false`면 이미 `unifiedNativeLoadFail`이 호출된 상태다.
    func handleNativeAdWithContentView() -> Bool {
        guard let nativeAd else {
            // 통지 없이 false를 반환하면 loader가 타임아웃(10초)까지 대기하므로 반드시 알린다.
            APLogger.error("Vungle UnifiedNative nativeAd is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Vungle nativeAd is nil")
            return false
        }

        guard let rootVC = rootViewController else {
            APLogger.error("Vungle UnifiedNative rootViewController is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return false
        }

        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Vungle placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Vungle contentView 생성 실패")
            return false
        }
        self.contentView = content

        // 1. 먼저 부착 — register 시점에 계층이 완성되어 있어야 한다.
        APSSPUnifiedNativeAssembler.attach(content, to: placeholder)

        // 2. 빈 슬롯 채우기 — MediaView는 어댑터가 생성
        let mediaView = MediaView()
        mediaView.delegate = self
        self.vungleMediaView = mediaView
        if !APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
            APLogger.error("Vungle UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        // 3. 데이터 바인딩
        content.titleLabel?.text = nativeAd.title
        content.bodyLabel?.text = nativeAd.bodyText

        let ctaText = nativeAd.callToAction
        if !ctaText.isEmpty {
            content.ctaButton?.setTitle(ctaText, for: .normal)
        }

        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()

        let sponsoredText = nativeAd.sponsoredText
        if !sponsoredText.isEmpty {
            content.sponsoredLabel?.text = sponsoredText
            visibleKeys.insert(.sponsored)
        }
        // 별점은 숫자로만 오므로 SDK가 화면에 반영한다.
        content.updateStarRating(NSNumber(value: nativeAd.adStarRating))
        content.hideOptionalViews(except: visibleKeys)

        // 4. Privacy 아이콘 위치 (register 전에 지정)
        nativeAd.adOptionsPosition = adOptionsPosition

        // 5. register — root는 content 자신.
        //    iconImageView는 매체 UIImageView를 그대로 넘기면 Vungle SDK가 이미지를 채운다.
        let candidates: [UIView?] = [content.titleLabel,
                                     content.bodyLabel,
                                     content.ctaButton,
                                     content.iconImageView]
        var clickableViews: [UIView] = candidates.compactMap { $0 }
        clickableViews.append(mediaView)

        nativeAd.registerViewForInteraction(view: content,
                                            mediaView: mediaView,
                                            iconImageView: content.iconImageView,
                                            viewController: rootVC,
                                            clickableViews: clickableViews)

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // 아이콘은 register가 채우므로 반드시 그 뒤에 판정한다.
        content.hideEmptyViews()
        return true
    }
}


// MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)
private extension VungleMediationUnifiedNativeAdView {

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func bindToViewBinder() {
        guard let nativeAd else { return }
        
        // 1. 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.title
        viewBinder.bodyLabel?.text = nativeAd.bodyText
        
        let ctaText = nativeAd.callToAction
        if !ctaText.isEmpty {
            viewBinder.ctaButton?.setTitle(ctaText, for: .normal)
        }
        
        // 2. 옵셔널 필드 바인딩
        var visibleKeys = Set<String>()
        
        let sponsoredText = nativeAd.sponsoredText
        if !sponsoredText.isEmpty {
            viewBinder.sponsoredLabel?.text = sponsoredText
            visibleKeys.insert("sponsored")
        }
        
        if nativeAd.adStarRating > 0 {
            visibleKeys.insert("starRating")
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // 3. MediaView → mediaContainerView에 삽입
        if viewBinder.mediaContainerView != nil {
            let mediaView = MediaView()
            mediaView.delegate = self
            viewBinder.insertMediaView(mediaView)
            self.vungleMediaView = mediaView
        }
        
        // 4. AdOptions 위치 설정 (Privacy 아이콘)
        nativeAd.adOptionsPosition = adOptionsPosition
        
        // 5. registerViewForInteraction 호출 (클릭 영역 등록)
        registerClickableViews()
    }
    
    func registerClickableViews() {
        guard let nativeAd,
              let containerView = viewBinder.containerView,
              let rootVC = rootViewController else {
            APLogger.error("Vungle UnifiedNative: cannot register - missing containerView or rootViewController")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Missing containerView or rootViewController")
            return
        }
        
        // 클릭 가능한 뷰 목록 구성
        var clickableViews: [UIView] = [containerView]
        
        if let ctaButton = viewBinder.ctaButton {
            clickableViews.append(ctaButton)
        }
        if let iconImageView = viewBinder.iconImageView {
            clickableViews.append(iconImageView)
        }
        
        // Vungle registerViewForInteraction 호출
        if let mediaView = vungleMediaView, let iconImageView = viewBinder.iconImageView {
            nativeAd.registerViewForInteraction(
                view: containerView,
                mediaView: mediaView,
                iconImageView: iconImageView,
                viewController: rootVC,
                clickableViews: clickableViews
            )
        } else if let mediaView = vungleMediaView {
            // iconImageView가 없는 경우
            nativeAd.registerViewForInteraction(
                view: containerView,
                mediaView: mediaView,
                iconImageView: nil,
                viewController: rootVC,
                clickableViews: clickableViews
            )
        } else {
            APLogger.error("Vungle UnifiedNative: mediaView is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "MediaView is nil")
            return
        }
    }
}


// MARK: - VungleNativeDelegate
extension VungleMediationUnifiedNativeAdView: VungleNativeDelegate {
    
    func nativeAdDidLoad(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did load")
        if viewBinder.isContentViewMode {
            APLogger.debug("Vungle UnifiedNative → 매체 XIB (신규 구조)")
            guard handleNativeAdWithContentView() else { return }
        } else {
            bindToViewBinder()
        }
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAdDidFailToLoad(_ native: VungleNative, withError: NSError) {
        APLogger.error("Vungle UnifiedNative load failed: \(withError.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: withError.localizedDescription)
    }
    
    func nativeAdDidTrackImpression(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did track impression")
        delegate?.unifiedNativeImpression(message: "Vungle UnifiedNative impression")
    }
    
    func nativeAdDidClick(_ native: VungleNative) {
        APLogger.debug("Vungle UnifiedNative did click")
        delegate?.unifiedNativeClicked(message: "Vungle UnifiedNative clicked")
    }
}


// MARK: - MediaViewDelegate
extension VungleMediationUnifiedNativeAdView: MediaViewDelegate {
    
    func mediaViewVideoDidPlay(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did play")
    }
    
    func mediaViewVideoDidPause(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did pause")
    }
    
    func mediaViewVideoDidEnd(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did end")
    }
    
    func mediaViewVideoDidMute(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did mute")
    }
    
    func mediaViewVideoDidUnmute(_ mediaView: MediaView) {
        APLogger.debug("Vungle UnifiedNative video did unmute")
    }
}
