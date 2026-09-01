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

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?
    
    
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
        // GFP SDK는 SimpleAd delegate 등록을 필수로 요구한다.
        // (등록하지 않으면 "native simnple delegate is not set" 오류로 로드 자체가 실패)
        // 따라서 delegate는 항상 등록하고, namUseSimpleAd = false 인 경우
        // SimpleAd를 수신했을 때 다음 미디에이션으로 넘긴다.
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
        gfpNativeAdView?.removeFromSuperview()
        gfpNativeAdView = nil
        simpleAdView?.removeFromSuperview()
        simpleAdView = nil
        contentView = nil
    }
}


// MARK: - SimpleAd 처리
private extension NAMMediationUnifiedNativeAdView {
    
    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
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


// MARK: - Custom GFPNativeAdView (hitTest override)
private class TransparentHitTestNativeAdView: GFPNativeAdView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // super.hitTest() 먼저 호출해서 GFPNativeAdView의 자식(info button 등)이 받아야 하는지 확인
        let hitView = super.hitTest(point, with: event)

        // 자식 뷰(info button 등)가 받아야 하면 그대로 리턴
        if let hitView = hitView, hitView !== self {
            return hitView
        }

        // GFPNativeAdView 자기 자신이면 (= 빈 영역) 터치 통과
        return nil
    }
}


// MARK: - [NEW] NativeAd — 매체 화면을 GFPNativeAdView 안에 넣는 방식
private extension NAMMediationUnifiedNativeAdView {

    /// 매체가 구성한 화면을 `GFPNativeAdView` **안에** 넣어 계층을 바로잡는다.
    /// 계층이 정상이므로 hitTest 우회 / 투명 오버레이가 필요 없다.
    /// - Returns: 조립 성공 여부. `false`면 호출부가 loadSuccess를 발화하면 안 된다.
    @discardableResult
    func handleNativeAdWithContentView(_ nativeAd: GFPNativeAd) -> Bool {
        self.nativeAd = nativeAd

        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM contentView 생성 실패")
            return false
        }
        self.contentView = content

        // 1. 업체 컨테이너 생성 + 매체 화면을 그 "안에" 삽입
        let adView = GFPNativeAdView()
        self.gfpNativeAdView = adView
        APSSPUnifiedNativeAssembler.wrap(content, in: adView)

        // 2. 빈 슬롯 채우기 — 업체 전용 뷰는 어댑터가 생성
        //    GFPNativeAdView.mediaView는 weak이므로 계층에 넣은 뒤 대입해야 한다.
        let mediaView = GFPMediaView()
        if APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
            adView.mediaView = mediaView
        } else {
            APLogger.error("NAM UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        if let adChoiceSlot = content.adChoiceContainerView {
            // NAM은 adChoicesView에 임의 UIView를 넘기면 SDK가 그 안에 그린다.
            adView.adChoicesView = adChoiceSlot
        }

        // 3. setter 등록 — 이제 모두 adView의 자손
        adView.titleLabel = content.titleLabel
        adView.bodyLabel = content.bodyLabel
        adView.iconView = content.iconImageView
        adView.advertiserLabel = content.advertiserLabel
        adView.socialContextLabel = content.socialContextLabel
        // NAM callToActionLabel은 UILabel만 받는다 (UIButton 직결 불가)
        adView.callToActionLabel = content.ctaButton?.titleLabel

        // 4. 데이터 바인딩
        content.titleLabel?.text = nativeAd.title
        content.bodyLabel?.text = nativeAd.body
        content.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)
        content.iconImageView?.image = nativeAd.iconData?.image

        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()
        if let advertiser = nativeAd.advertiser, !advertiser.isEmpty {
            content.advertiserLabel?.text = advertiser
            visibleKeys.insert(.advertiser)
        }
        if let socialContext = nativeAd.socialContext, !socialContext.isEmpty {
            content.socialContextLabel?.text = socialContext
            visibleKeys.insert(.socialContext)
        }
        // AdChoices는 GFP가 nativeAd 대입 시점에 슬롯 안에 그린다. 슬롯이 있으면 노출한다.
        if content.adChoiceContainerView != nil {
            visibleKeys.insert(.adChoice)
        }
        content.hideOptionalViews(except: visibleKeys)

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // hidesEmptySlots: false — GFP는 아래 nativeAd 대입 시점에 AdChoices 슬롯을 채우므로,
        // 여기서 "자식 없음"으로 판정해 숨기면 AdChoices가 표시되지 않는다. (노출 정책 위반 위험)
        content.hideEmptyViews(hidesEmptySlots: false)

        // 5. nativeAd 연결 — 반드시 마지막 (미디어 렌더 + 트래킹 시작)
        adView.nativeAd = nativeAd
        nativeAd.delegate = self

        // 6. 플레이스홀더에 부착
        APSSPUnifiedNativeAssembler.attach(adView, to: placeholder)
        return true
    }

    /// SimpleAd는 NAM SDK가 광고 전체를 렌더하므로 매체 화면을 쓸 수 없다.
    /// 플레이스홀더에 SimpleAdView를 통째로 부착한다.
    @discardableResult
    func handleSimpleAdWithContentView(_ nativeSimpleAd: GFPNativeSimpleAd) -> Bool {
        self.nativeSimpleAd = nativeSimpleAd
        nativeSimpleAd.delegate = self

        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM placeholder is nil")
            return false
        }

        let adView = GFPNativeSimpleAdView()
        self.simpleAdView = adView

        // SimpleAd는 mediaView 세팅이 필수
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

        adView.nativeAd = nativeSimpleAd
        APSSPUnifiedNativeAssembler.attach(adView, to: placeholder)
        return true
    }
}


// MARK: - [LEGACY] NativeAd — ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)
private extension NAMMediationUnifiedNativeAdView {

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func handleNativeAd(_ nativeAd: GFPNativeAd) {
        self.nativeAd = nativeAd

        guard let container = viewBinder.containerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM containerView is nil")
            return
        }

        guard let mediaContainer = viewBinder.mediaContainerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "NAM mediaContainerView is nil")
            return
        }

        // GFPNativeAdView 생성 (hitTest override 버전)
        let adView = TransparentHitTestNativeAdView()
        self.gfpNativeAdView = adView

        // ✅ Android처럼: mediaView를 mediaContainerView에 배치
        let mediaView = GFPMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.subviews.forEach { $0.removeFromSuperview() }
        mediaContainer.addSubview(mediaView)
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
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

        // ✅ Android처럼: GFPNativeAdView를 containerView 전체에 추가 (최상단)
        container.subviews.filter { $0 is GFPNativeAdView }.forEach { $0.removeFromSuperview() }
        adView.frame = container.bounds
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        adView.backgroundColor = .clear  // 투명
        container.addSubview(adView)  // ✅ 최상단에 올림 (overlay가 모든 걸 덮도록)

        // hitTest override로 adChoicesView 영역만 터치 받고 나머지는 통과

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

        // namUseSimpleAd = false 면 매체 레이아웃을 지켜야 하므로 SimpleAd를 사용하지 않는다.
        guard config?.namUseSimpleAd ?? true else {
            APLogger.debug("NAM UnifiedNative: SimpleAd 수신했으나 namUseSimpleAd=false → 다음 미디에이션")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "SimpleAd disabled by config")
            return
        }

        if viewBinder.isContentViewMode {
            APLogger.debug("NAM UnifiedNative → SimpleAd (SDK 자체 렌더 — 매체 XIB 미적용)")
            // 조립 실패 시 이미 loadFail을 보고했으므로 success를 중복 발화하지 않는다.
            guard handleSimpleAdWithContentView(nativeSimpleAd) else { return }
        } else {
            handleSimpleAd(nativeSimpleAd)
        }
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
        if viewBinder.isContentViewMode {
            APLogger.debug("NAM UnifiedNative → NativeAd + 매체 XIB (신규 구조)")
            // 조립 실패 시 이미 loadFail을 보고했으므로 success를 중복 발화하지 않는다.
            guard handleNativeAdWithContentView(nativeAd) else { return }
        } else {
            handleNativeAd(nativeAd)
        }
        delegate?.unifiedNativeLoadSuccess()
    }
    
    public func nativeAdWasSeen(_ nativeAd: GFPNativeAd) {
        delegate?.unifiedNativeImpression(message: "NAM UnifiedNative NativeAd impression")
    }
    
    public func nativeAdWasClicked(_ nativeAd: GFPNativeAd) {
        delegate?.unifiedNativeClicked(message: "NAM UnifiedNative NativeAd clicked")
    }
}
