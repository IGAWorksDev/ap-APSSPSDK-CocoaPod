//
//  FBAudienceNetworkMediationUnifiedNativeAdView.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import FBAudienceNetwork
import APSSPSDK


/// FAN 통합형 네이티브 광고의 실제 로드/바인딩 담당.
/// FBNativeAd를 로드하고, ViewBinder에 데이터를 바인딩합니다.
/// registerViewForInteraction 호출이 필수입니다.
final class FBAudienceNetworkMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private let biddingData: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAd: FBNativeAd?
    private var mediaView: FBMediaView?
    private var iconView: FBMediaView?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?

    /// 신규(레시피) 방식에서 어댑터가 생성한 AdChoices 뷰
    private var adChoicesView: FBAdChoicesView?

    
    init(placementId: String, biddingData: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
        self.placementId = placementId
        self.biddingData = biddingData
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        APLogger.debug("FBAudienceNetworkMediationUnifiedNativeAdView deinit")
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("FAN UnifiedNative placementId is empty")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        nativeAd = FBNativeAd(placementID: placementId)
        nativeAd?.delegate = self
        nativeAd?.loadAd(withBidPayload: biddingData)
    }
    
    func stop() {
        nativeAd?.unregisterView()
        nativeAd = nil
        mediaView = nil
        iconView = nil
        adChoicesView = nil
        contentView?.removeFromSuperview()
        contentView = nil
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension FBAudienceNetworkMediationUnifiedNativeAdView {

    /// Meta는 업체 컨테이너 클래스가 없고 `registerViewForInteraction`으로 명시 등록한다.
    /// `clickableViews`는 모두 `forInteraction:`으로 넘긴 root의 **자손**이어야 하므로,
    /// root를 매체 화면(content) 자신으로 넘겨 조건을 자동으로 충족시킨다.
    /// - Returns: 조립 성공 여부. `false`면 호출부가 loadSuccess를 발화하면 안 된다.
    @discardableResult
    func bindToContentView() -> Bool {
        guard let nativeAd, nativeAd.isAdValid else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN native ad invalid")
            return false
        }

        guard let placeholder = viewBinder.resolvedPlaceholder else {
            APLogger.error("FAN UnifiedNative placeholder is nil")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            APLogger.error("FAN UnifiedNative contentView 생성 실패")
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN contentView 생성 실패")
            return false
        }
        self.contentView = content

        nativeAd.unregisterView()

        // 1. 컨테이너가 없는 업체이므로 매체 화면을 곧바로 플레이스홀더에 부착
        APSSPUnifiedNativeAssembler.attach(content, to: placeholder)

        // 2. 빈 슬롯 채우기 — 업체 전용 뷰는 어댑터가 생성
        let coverMediaView = FBMediaView()
        self.mediaView = coverMediaView
        if !APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: coverMediaView) {
            APLogger.error("FAN UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        let adChoices = FBAdChoicesView(nativeAd: nativeAd)
        adChoices.rootViewController = rootViewController
        let hasAdChoice = APSSPUnifiedNativeAssembler.fillSlot(content.adChoiceContainerView, with: adChoices)
        self.adChoicesView = hasAdChoice ? adChoices : nil

        // 3. 데이터 바인딩 — title은 headline, 광고주명은 advertiserLabel
        content.titleLabel?.text = nativeAd.headline
        content.bodyLabel?.text = nativeAd.bodyText
        content.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)

        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()

        if let advertiserName = nativeAd.advertiserName, !advertiserName.isEmpty {
            content.advertiserLabel?.text = advertiserName
            visibleKeys.insert(.advertiser)
        }
        if let socialContext = nativeAd.socialContext, !socialContext.isEmpty {
            content.socialContextLabel?.text = socialContext
            visibleKeys.insert(.socialContext)
        }
        if let sponsored = nativeAd.sponsoredTranslation, !sponsored.isEmpty {
            content.sponsoredLabel?.text = sponsored
            visibleKeys.insert(.sponsored)
        }
        if hasAdChoice {
            visibleKeys.insert(.adChoice)
        }

        // 옵셔널 뷰 처리는 한 번만 수행
        content.hideOptionalViews(except: visibleKeys)

        // 4. registerView (필수 — 클릭/impression 등록)
        //    iconView: 파라미터는 FBMediaView만 받지만, UIImageView를 받는 오버로드가 있어
        //    매체 iconImageView를 그대로 사용할 수 있다. (SDK가 아이콘 이미지를 채워준다)
        var clickableViews: [UIView] = []
        if let view = content.titleLabel { clickableViews.append(view) }
        if let view = content.bodyLabel { clickableViews.append(view) }
        if let view = content.ctaButton { clickableViews.append(view) }
        if let view = content.iconImageView { clickableViews.append(view) }
        if visibleKeys.contains(.advertiser), let view = content.advertiserLabel { clickableViews.append(view) }
        if visibleKeys.contains(.socialContext), let view = content.socialContextLabel { clickableViews.append(view) }
        if visibleKeys.contains(.sponsored), let view = content.sponsoredLabel { clickableViews.append(view) }
        clickableViews.append(coverMediaView)

        nativeAd.registerView(
            forInteraction: content,
            mediaView: coverMediaView,
            iconImageView: content.iconImageView,
            viewController: rootViewController,
            clickableViews: clickableViews
        )

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // 아이콘은 registerView가 채우므로 반드시 그 뒤에 판정한다.
        content.hideEmptyViews()
        return true
    }
}


// MARK: - [LEGACY] ViewBinder 참조 방식 — 제거 예정 (grep: APSSP-LEGACY)
private extension FBAudienceNetworkMediationUnifiedNativeAdView {

    /// APSSP-LEGACY: ViewBinder 참조 방식. 신규 ContentView 방식으로 대체됨 — 다음 메이저에서 제거 대상.
    func bindToViewBinder() {
        guard let nativeAd, nativeAd.isAdValid else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN native ad invalid")
            return
        }
        
        nativeAd.unregisterView()
        
        // 텍스트 바인딩
        viewBinder.titleLabel?.text = nativeAd.advertiserName
        viewBinder.bodyLabel?.text = nativeAd.bodyText
        viewBinder.ctaButton?.setTitle(nativeAd.callToAction, for: .normal)
        
        // 옵셔널 필드
        var visibleKeys = Set<String>()
        
        if let socialContext = nativeAd.socialContext, !socialContext.isEmpty {
            viewBinder.socialContextLabel?.text = socialContext
            visibleKeys.insert("socialContext")
        }
        if let sponsored = nativeAd.sponsoredTranslation, !sponsored.isEmpty {
            viewBinder.sponsoredLabel?.text = sponsored
            visibleKeys.insert("sponsored")
        }
        
        viewBinder.hideOptionalViews(except: visibleKeys)
        
        // MediaView → mediaContainerView
        let coverMediaView = FBMediaView()
        mediaView = coverMediaView
        if let _ = viewBinder.mediaContainerView {
            viewBinder.insertMediaView(coverMediaView)
        }
        
        // Icon → iconImageView (FBMediaView로 대체)
        let fbIconView = FBMediaView()
        iconView = fbIconView
        if let iconImageView = viewBinder.iconImageView {
            fbIconView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.superview?.insertSubview(fbIconView, aboveSubview: iconImageView)
            NSLayoutConstraint.activate([
                fbIconView.topAnchor.constraint(equalTo: iconImageView.topAnchor),
                fbIconView.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
                fbIconView.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
                fbIconView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor)
            ])
            iconImageView.isHidden = true
        }
        
        // registerViewForInteraction (필수 — 클릭/impression 등록)
        guard let container = viewBinder.containerView else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "FAN containerView is nil")
            return
        }
        
        var clickableViews: [UIView] = []
        if let v = viewBinder.titleLabel { clickableViews.append(v) }
        if let v = viewBinder.bodyLabel { clickableViews.append(v) }
        if let v = viewBinder.ctaButton { clickableViews.append(v) }
        if let v = viewBinder.socialContextLabel { clickableViews.append(v) }
        if let v = viewBinder.sponsoredLabel { clickableViews.append(v) }
        clickableViews.append(coverMediaView)
        
        nativeAd.registerView(
            forInteraction: container,
            mediaView: coverMediaView,
            iconView: fbIconView,
            viewController: rootViewController,
            clickableViews: clickableViews
        )
        
        // AdChoice 처리
        if let adChoiceContainer = viewBinder.adChoiceContainerView {
            let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
            adChoicesView.translatesAutoresizingMaskIntoConstraints = false
            adChoiceContainer.addSubview(adChoicesView)
            NSLayoutConstraint.activate([
                adChoicesView.topAnchor.constraint(equalTo: adChoiceContainer.topAnchor),
                adChoicesView.trailingAnchor.constraint(equalTo: adChoiceContainer.trailingAnchor)
            ])
            visibleKeys.insert("adChoice")
            viewBinder.hideOptionalViews(except: visibleKeys)
        }
    }
}


// MARK: - FBNativeAdDelegate
extension FBAudienceNetworkMediationUnifiedNativeAdView: FBNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        self.nativeAd = nativeAd
        if viewBinder.isContentViewMode {
            APLogger.debug("FAN UnifiedNative → 매체 XIB (신규 구조)")
            // 조립 실패 시 이미 loadFail을 보고했으므로 success를 중복 발화하지 않는다.
            guard bindToContentView() else { return }
        } else {
            bindToViewBinder()
        }
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        APLogger.error("FAN UnifiedNative Error: \(error.localizedDescription)")
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        delegate?.unifiedNativeClicked(message: "FAN UnifiedNative clicked")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        delegate?.unifiedNativeImpression(message: "FAN UnifiedNative impression")
    }
}
