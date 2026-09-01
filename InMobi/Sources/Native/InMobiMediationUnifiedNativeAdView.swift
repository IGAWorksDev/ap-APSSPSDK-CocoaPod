//
//  InMobiMediationUnifiedNativeAdView.swift
//  MediationInMobi
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import InMobiSDK
import APSSPSDK


final class InMobiMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAd: IMNative?

    /// InMobi가 제공하는 미디어 뷰. 트래킹 등록(setExtraViews)에도 사용한다.
    private var inMobiMediaView: UIView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?


    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("InMobiMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard let pid = Int64(placementId), pid > 0 else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "InMobi placementId is invalid")
            return
        }
        
        nativeAd = IMNative(placementId: pid, delegate: self)
        nativeAd?.load()
    }
    
    func stop() {
        nativeAd?.delegate = nil
        nativeAd = nil
        inMobiMediaView?.removeFromSuperview()
        inMobiMediaView = nil
        contentView?.removeFromSuperview()
        contentView = nil
    }

    // MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용

    /// 매체가 만든 화면(`APSSPUnifiedNativeAdView`)을 플레이스홀더에 부착하고,
    /// 그 화면 자신을 `adParentView`로 넘긴다.
    /// InMobi는 컨테이너 클래스가 없으므로 등록 뷰가 adParentView의 자손이기만 하면 된다.
    /// - Returns: 조립 성공 여부. `false`면 이미 `unifiedNativeLoadFail`이 호출된 상태다.
    private func handleNativeAdWithContentView() -> Bool {
        guard let nativeAd else { return false }

        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "InMobi placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "InMobi contentView 생성 실패")
            return false
        }
        self.contentView = content

        // 1. 먼저 부착 — registerViewForTracking 시점에 계층이 완성되어 있어야 한다.
        APSSPUnifiedNativeAssembler.attach(content, to: placeholder)

        // 2. 빈 슬롯 채우기 — MediaView는 InMobi SDK가 제공
        let mediaView = nativeAd.getMediaView()
        self.inMobiMediaView = mediaView
        if let mediaView {
            if !APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
                APLogger.error("InMobi UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
            }
        }

        // 3. AdChoices 슬롯 채우기
        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()
        if let adChoice = nativeAd.adChoice,
           APSSPUnifiedNativeAssembler.fillSlot(content.adChoiceContainerView, with: adChoice) {
            visibleKeys.insert(.adChoice)
        }

        // 4. 데이터 바인딩
        content.titleLabel?.text = nativeAd.adTitle
        content.bodyLabel?.text = nativeAd.adDescription
        content.ctaButton?.setTitle(nativeAd.adCtaText, for: .normal)
        if let iconImage = nativeAd.adIcon?.imageview?.image {
            content.iconImageView?.image = iconImage
        }

        if let advertiser = nativeAd.advertiserName, !advertiser.isEmpty {
            content.advertiserLabel?.text = advertiser
            visibleKeys.insert(.advertiser)
        }
        content.hideOptionalViews(except: visibleKeys)

        // 5. 트래킹 등록 — adParentView는 content 자신 (반드시 마지막)
        let builder = IMNativeViewData.Builder(adParentView: content)
        if let title = content.titleLabel { builder.setTitleView(title) }
        if let desc = content.bodyLabel { builder.setDescriptionView(desc) }
        if let cta = content.ctaButton { builder.setCTAView(cta) }
        if let icon = content.iconImageView { builder.setIconView(icon) }
        if let advertiser = content.advertiserLabel { builder.setAdvertiserView(advertiser) }
        if let rating = content.starRatingView { builder.setRatingView(rating) }

        // mediaView를 등록하지 않으면 미디어 영역 클릭이 추적되지 않는다.
        var extraViews: [UIView] = []
        if let mediaView { extraViews.append(mediaView) }
        if !extraViews.isEmpty { builder.setExtraViews(extraViews) }

        nativeAd.registerViewForTracking(builder.build())

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        content.hideEmptyViews()
        return true
    }

    // MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    private func bindToViewBinder() {
        guard let nativeAd else { return }
        
        viewBinder.titleLabel?.text = nativeAd.adTitle
        viewBinder.bodyLabel?.text = nativeAd.adDescription
        viewBinder.ctaButton?.setTitle(nativeAd.adCtaText, for: .normal)
        
        // Icon
        if let iconImage = nativeAd.adIcon?.imageview?.image {
            viewBinder.iconImageView?.image = iconImage
        }
        
        // MediaView (primaryView) → mediaContainerView에 삽입
        let mediaView = nativeAd.getMediaView()
        self.inMobiMediaView = mediaView
        if let mediaView {
            viewBinder.insertMediaView(mediaView)
        }

        // 옵셔널 필드
        var visibleKeys = Set<String>()
        if let advertiser = nativeAd.advertiserName, !advertiser.isEmpty {
            viewBinder.advertiserLabel?.text = advertiser
            visibleKeys.insert("advertiser")
        }
        // AdChoices → adChoiceContainerView
        if let adChoice = nativeAd.adChoice,
           APSSPUnifiedNativeAssembler.fillSlot(viewBinder.adChoiceContainerView, with: adChoice) {
            visibleKeys.insert("adChoice")
        }
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // Tracking 등록
        registerTracking()
    }
    
    private func registerTracking() {
        guard let nativeAd, let container = viewBinder.containerView else { return }
        
        let builder = IMNativeViewData.Builder(adParentView: container)
        if let title = viewBinder.titleLabel { builder.setTitleView(title) }
        if let desc = viewBinder.bodyLabel { builder.setDescriptionView(desc) }
        if let cta = viewBinder.ctaButton { builder.setCTAView(cta) }
        if let icon = viewBinder.iconImageView { builder.setIconView(icon) }
        if let advertiser = viewBinder.advertiserLabel { builder.setAdvertiserView(advertiser) }
        if let rating = viewBinder.starRatingView { builder.setRatingView(rating) }

        // mediaView를 등록하지 않으면 미디어 영역 클릭이 추적되지 않는다.
        if let mediaView = inMobiMediaView { builder.setExtraViews([mediaView]) }

        nativeAd.registerViewForTracking(builder.build())
    }
}

extension InMobiMediationUnifiedNativeAdView: IMNativeDelegate {
    func nativeDidFinishLoading(_ native: IMNative) {
        if viewBinder.isContentViewMode {
            APLogger.debug("InMobi UnifiedNative → 매체 XIB (신규 구조)")
            guard handleNativeAdWithContentView() else { return }
        } else {
            bindToViewBinder()
        }
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func native(_ native: IMNative, didFailToLoadWithError error: IMRequestStatus) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdImpressed(_ native: IMNative) {
        delegate?.unifiedNativeImpression(message: "InMobi UnifiedNative impression")
    }
    
    func native(_ native: IMNative, didInteractWithParams params: [String: Any]?) {
        delegate?.unifiedNativeClicked(message: "InMobi UnifiedNative clicked")
    }
}
