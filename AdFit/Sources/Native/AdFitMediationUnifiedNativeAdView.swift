//
//  AdFitMediationUnifiedNativeAdView.swift
//  MediationAdFit
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import AdFitSDK
import APSSPSDK


// MARK: - [LEGACY] Custom 래퍼 뷰 (ViewBinder 참조) — 제거 예정 (grep: APSSP-LEGACY)

private final class AdFitCustomNativeAdView: UIView, AdFitNativeAdRenderable {

    private weak var viewBinder: APSSPMediationViewBinder?
    private let mediaView = AdFitMediaView()

    init(viewBinder: APSSPMediationViewBinder) {
        self.viewBinder = viewBinder
        super.init(frame: .zero)
        setupMediaView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupMediaView() {
        guard let container = viewBinder?.mediaContainerView else { return }

        container.subviews.forEach { $0.removeFromSuperview() }
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mediaView)

        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: container.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: - AdFitNativeAdRenderable

    func adTitleLabel() -> UILabel? { viewBinder?.titleLabel }
    func adBodyLabel() -> UILabel? { viewBinder?.bodyLabel }
    func adCallToActionButton() -> UIButton? { viewBinder?.ctaButton }
    func adProfileNameLabel() -> UILabel? { viewBinder?.adFitProfileNameLabel }
    func adProfileIconView() -> UIImageView? { viewBinder?.adFitProfileIconView }
    func adMediaView() -> AdFitMediaView? { mediaView }
}


// MARK: - [NEW] Renderable 컨테이너 — 매체 화면을 감싸는 실제 계층

/// AdFit은 `AdFitNativeAdRenderable`을 conform한 **뷰**를 `nativeAd.bind(_:)`에 넘기면
/// 그 뷰를 기준으로 에셋 바인딩과 infoIcon(AdChoices) 배치를 수행한다.
///
/// 기존 방식은 renderable 구현체가 어떤 뷰 계층에도 추가되지 않는 **고아 뷰**여서
/// AdFit SDK가 그린 infoIcon이 화면에 표시될 자리가 없었다.
/// (Android는 `AdFitNativeAdView` 컨테이너를 동적 생성해 계층에 넣는다.)
///
/// 이 클래스는 renderable 구현체 자체를 **컨테이너**로 삼아
/// 매체 화면(`APSSPUnifiedNativeAdView`)을 그 안에 넣고, 컨테이너를 placeholder에 부착한다.
/// 따라서 infoIcon이 이 컨테이너의 자식으로 정상 표시된다.
private final class AdFitRenderableContainerView: UIView, AdFitNativeAdRenderable {

    private let content: APSSPUnifiedNativeAdView
    private let mediaView = AdFitMediaView()

    /// `adProfileNameLabel()` / `adProfileIconView()`는 프로토콜 **필수** 메서드다.
    /// 매체 XIB에 해당 outlet이 없을 때 AdFit SDK가 nil을 다루지 못해 문제가 생기는 것을 막기 위한 안전 대체 뷰.
    /// 계층에는 포함하되 크기 0 / 숨김 상태라 화면에는 영향이 없다.
    private let fallbackProfileNameLabel = UILabel(frame: .zero)
    private let fallbackProfileIconView = UIImageView(frame: .zero)

    init(content: APSSPUnifiedNativeAdView) {
        self.content = content
        super.init(frame: .zero)

        // 1. 매체 화면을 컨테이너 "안에" 삽입 (파괴적 정리 없음)
        APSSPUnifiedNativeAssembler.wrap(content, in: self)

        // 2. 빈 미디어 슬롯을 AdFit 전용 MediaView로 채운다
        if !APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
            APLogger.error("AdFit UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
            // 슬롯이 없어도 MediaView는 계층에 있어야 AdFit SDK가 안전하게 동작한다.
            mediaView.isHidden = true
            addSubview(mediaView)
        }

        // 3. 대체 프로필 뷰 준비
        fallbackProfileNameLabel.isHidden = true
        fallbackProfileIconView.isHidden = true
        addSubview(fallbackProfileNameLabel)
        addSubview(fallbackProfileIconView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - AdFitNativeAdRenderable

    @objc func adTitleLabel() -> UILabel? { content.titleLabel }
    @objc func adBodyLabel() -> UILabel? { content.bodyLabel }
    @objc func adCallToActionButton() -> UIButton? { content.ctaButton }
    @objc func adProfileNameLabel() -> UILabel? { content.adFitProfileNameLabel ?? fallbackProfileNameLabel }
    @objc func adProfileIconView() -> UIImageView? { content.adFitProfileIconView ?? fallbackProfileIconView }
    @objc func adMediaView() -> AdFitMediaView? { mediaView }
}


// MARK: - AdFitMediationUnifiedNativeAdView

final class AdFitMediationUnifiedNativeAdView: UIView {

    weak var delegate: APSSPUnifiedNativeAdapterDelegate?

    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?

    private var nativeAdLoader: AdFitNativeAdLoader?
    private let bizboardTemplate = BizBoardTemplate()
    private var customNativeAdView: AdFitCustomNativeAdView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?

    /// 신규(레시피) 방식에서 생성한 renderable 컨테이너
    private var renderableContainerView: AdFitRenderableContainerView?


    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { APLogger.debug("AdFitMediationUnifiedNativeAdView deinit") }

    func load() {
        guard !placementId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AdFit placementId is empty")
            return
        }

        nativeAdLoader = AdFitNativeAdLoader(clientId: placementId)
        nativeAdLoader?.delegate = self
        nativeAdLoader?.loadAd()
    }

    func stop() {
        nativeAdLoader?.delegate = nil
        nativeAdLoader = nil
        customNativeAdView = nil
        renderableContainerView?.removeFromSuperview()
        renderableContainerView = nil
        contentView = nil
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension AdFitMediationUnifiedNativeAdView {

    /// renderable 구현체를 **실제 뷰 계층에 넣고** bind 한다.
    /// 순서: wrap(content, in: renderable) → 데이터/옵셔널 처리 → attach(renderable, to: placeholder) → bind
    func handleNativeAdWithContentView(_ nativeAd: AdFitNativeAd) {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AdFit placeholder is nil")
            return
        }

        // BizBoard는 템플릿 하나로 광고 전체를 렌더하므로 매체 XIB를 적용할 수 없다.
        if config?.adFitBizBoard ?? false {
            APLogger.debug("AdFit UnifiedNative → BizBoard 템플릿 (SDK 자체 렌더 — 매체 XIB 미적용)")
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            APSSPUnifiedNativeAssembler.attach(bizboardTemplate, to: placeholder)
            delegate?.unifiedNativeLoadSuccess()
            return
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AdFit contentView 생성 실패")
            return
        }
        self.contentView = content

        // 1. renderable 컨테이너 생성 — 내부에서 wrap + mediaView 슬롯 채우기까지 수행
        let renderableView = AdFitRenderableContainerView(content: content)
        self.renderableContainerView = renderableView

        // 2. AdFit이 지원하지 않는 옵셔널 뷰는 먼저 숨긴다.
        //    프로필/AdChoice는 bind가 값을 채운 뒤 hideEmptyViews()가 값 기준으로 판정한다.
        //    (뷰 존재 여부로 판정하면 값이 없어도 계속 표시되므로 그렇게 하지 않는다)
        content.hideOptionalViews(except: [.adFitProfileName, .adFitProfileIcon, .adChoice])

        // 3. 계층 부착 — bind 이전에 계층에 올려야 infoIcon(AdChoices)이 그려질 자리가 생긴다
        APSSPUnifiedNativeAssembler.attach(renderableView, to: placeholder)

        // 4. bind — 텍스트/이미지 바인딩 + infoIcon 배치 + 클릭 트래킹 시작
        nativeAd.infoIconRightConstant = -16
        nativeAd.rootViewController = rootViewController
        nativeAd.delegate = self
        nativeAd.bind(renderableView)

        // 5. bind가 값을 채운 뒤이므로, 광고에 없는 에셋(CTA/아이콘 등)의 뷰를 숨긴다.
        //    XIB placeholder가 그대로 남는 것을 방지한다.
        content.hideEmptyViews()

        delegate?.unifiedNativeLoadSuccess()
    }
}


// MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)
private extension AdFitMediationUnifiedNativeAdView {

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func handleNativeAd(_ nativeAd: AdFitNativeAd) {
        let useBizBoard = config?.adFitBizBoard ?? false

        var visibleKeys = Set<String>()

        if useBizBoard {
            // BizBoard 템플릿 사용
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(bizboardTemplate)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self
            bizboardTemplate.autoresizingMask = .flexibleWidth
            viewBinder.insertMediaView(bizboardTemplate)
        } else {
            // Custom 연동 - MediationViewBinder 사용
            customNativeAdView = AdFitCustomNativeAdView(viewBinder: viewBinder)
            nativeAd.infoIconRightConstant = -16
            nativeAd.bind(customNativeAdView!)
            nativeAd.rootViewController = rootViewController
            nativeAd.delegate = self

            // AdFit 전용 옵셔널 뷰 visible 처리
            if viewBinder.adFitProfileNameLabel != nil {
                visibleKeys.insert("adFitProfileName")
            }
            if viewBinder.adFitProfileIconView != nil {
                visibleKeys.insert("adFitProfileIcon")
            }
        }

        viewBinder.hideOptionalViews(except: visibleKeys)
        delegate?.unifiedNativeLoadSuccess()
    }
}


// MARK: - AdFit Delegate

extension AdFitMediationUnifiedNativeAdView: AdFitNativeAdLoaderDelegate, AdFitNativeAdDelegate {

    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        if viewBinder.isContentViewMode {
            APLogger.debug("AdFit UnifiedNative → 매체 XIB (신규 구조)")
            handleNativeAdWithContentView(nativeAd)
        } else {
            handleNativeAd(nativeAd)
        }
    }

    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
        delegate?.unifiedNativeClicked(message: "AdFit UnifiedNative clicked")
    }
}
