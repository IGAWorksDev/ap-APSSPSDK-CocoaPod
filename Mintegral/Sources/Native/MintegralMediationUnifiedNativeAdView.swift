//
//  MintegralMediationUnifiedNativeAdView.swift
//  MediationMintegral
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import MTGSDK
import MTGSDKBidding
import APSSPSDK


final class MintegralMediationUnifiedNativeAdView: UIView {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private let unitId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    
    private var nativeAdManager: MTGNativeAdManager?
    private var bidNativeAdManager: MTGBidNativeAdManager?
    private var mediaView: MTGMediaView?
    private var biddingData: String?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?

    /// `MTGAdChoicesView.campaign`이 weak이므로 campaign을 강하게 보유해야 아이콘이 유지된다.
    private var campaign: MTGCampaign?
    private var adChoicesView: MTGAdChoicesView?


    init(placementId: String, unitId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, biddingData: String? = nil) {
        self.placementId = placementId
        self.unitId = unitId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { APLogger.debug("MintegralMediationUnifiedNativeAdView deinit") }
    
    func load() {
        guard !unitId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral unitId is empty")
            return
        }
        
        guard let rootViewController else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        APLogger.debug("Start Mintegral UnifiedNative load, placementId: \(placementId), UnitID: \(unitId), bidding: \(biddingData != nil)")
        
        if let biddingData, !biddingData.isEmpty {
            // Bidding: MTGBidNativeAdManager 사용
            bidNativeAdManager = MTGBidNativeAdManager(placementId: placementId,
                                                       unitID: unitId,
                                                       presenting: rootViewController)
            bidNativeAdManager?.delegate = self
            bidNativeAdManager?.load(withBidToken: biddingData)
        } else {
            // Waterfall: MTGNativeAdManager 사용
            var templates: [Any] = []
               if let template = MTGTemplate(type: .MTGAD_TEMPLATE_BIG_IMAGE, adsNum: 1) {
                   templates.append(template)
               }
            
            nativeAdManager = MTGNativeAdManager(placementId: placementId,
                                                 unitID: unitId,
                                                 supportedTemplates: templates,
                                                 autoCacheImage: false,
                                                 adCategory: .MTGAD_CATEGORY_ALL,
                                                 presenting: rootViewController)
            nativeAdManager?.delegate = self
            nativeAdManager?.loadAds()
        }
    }
    
    func stop() {
        nativeAdManager?.delegate = nil
        nativeAdManager = nil
        bidNativeAdManager?.delegate = nil
        bidNativeAdManager = nil
        mediaView?.delegate = nil
        mediaView = nil
        adChoicesView?.removeFromSuperview()
        adChoicesView = nil
        campaign = nil
        contentView?.removeFromSuperview()
        contentView = nil
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension MintegralMediationUnifiedNativeAdView {

    /// 매체가 만든 화면(`APSSPUnifiedNativeAdView`)을 플레이스홀더에 부착하고,
    /// 그 화면 자신을 register root로 넘긴다.
    /// Mintegral은 컨테이너 클래스가 없으므로 clickableViews가 root의 자손이기만 하면 된다.
    /// - Returns: 조립 성공 여부. `false`면 이미 `unifiedNativeLoadFail`이 호출된 상태다.
    func handleNativeAdWithContentView(_ campaign: MTGCampaign) -> Bool {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral contentView 생성 실패")
            return false
        }
        self.contentView = content
        self.campaign = campaign

        // 1. 먼저 부착 — register 시점에 계층이 완성되어 있어야 한다.
        APSSPUnifiedNativeAssembler.attach(content, to: placeholder)

        // 2. 빈 슬롯 채우기 — MediaView는 어댑터가 생성.
        //    setMediaSourceWithCampaign:unitId:는 계층에 넣은 뒤 호출한다.
        let mtgMediaView = MTGMediaView()
        mtgMediaView.delegate = self
        self.mediaView = mtgMediaView
        if APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mtgMediaView) {
            mtgMediaView.setMediaSourceWith(campaign, unitId: unitId)
        } else {
            APLogger.error("Mintegral UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        // 3. AdChoices 슬롯 채우기 (campaign이 weak이므로 self.campaign으로 강한 참조 유지)
        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()
        if content.adChoiceContainerView != nil {
            let choicesView = MTGAdChoicesView(frame: .zero)
            choicesView.campaign = campaign
            self.adChoicesView = choicesView
            if APSSPUnifiedNativeAssembler.fillSlot(content.adChoiceContainerView, with: choicesView) {
                visibleKeys.insert(.adChoice)
            }
        }

        // 4. 데이터 바인딩
        content.titleLabel?.text = campaign.appName
        content.bodyLabel?.text = campaign.appDesc
        content.ctaButton?.setTitle(campaign.adCall, for: .normal)

        // 아이콘은 비동기로 도착하므로 완료 시점에 직접 노출 여부를 결정한다.
        campaign.loadIconUrlAsync { [weak content] image in
            if let image { content?.iconImageView?.image = image }
            content?.iconImageView?.isHidden = (image == nil)
        }

        content.hideOptionalViews(except: visibleKeys)

        // 광고에 없는 에셋(CTA 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // 아이콘은 이 시점에 아직 nil이라 오판되므로 판정에서 제외하고 위 콜백에서 처리한다.
        content.hideEmptyViews(hidesIconWhenEmpty: false)

        // 5. register — root는 content 자신 (반드시 마지막)
        let candidates: [UIView?] = [content.titleLabel,
                                     content.bodyLabel,
                                     content.ctaButton,
                                     content.iconImageView]
        var clickableViews: [UIView] = candidates.compactMap { $0 }
        clickableViews.append(mtgMediaView)

        if let bidLoader = bidNativeAdManager {
            bidLoader.registerView(forInteraction: content, withClickableViews: clickableViews, with: campaign)
        } else {
            nativeAdManager?.registerView(forInteraction: content, withClickableViews: clickableViews, with: campaign)
        }
        return true
    }
}

extension MintegralMediationUnifiedNativeAdView: MTGNativeAdManagerDelegate, MTGBidNativeAdManagerDelegate, MTGMediaViewDelegate {

    // MARK: - Bidding 경로
    // SDK가 bidding 전용 delegate 메서드를 `bidNativeManager:` 라벨로 별도 정의한다.
    // 이 메서드들이 없으면 인앱비딩 로드 결과가 전달되지 않는다. (전 메서드 @optional이라 컴파일은 통과)

    func nativeAdsLoaded(_ nativeAds: [Any]?, bidNativeManager: MTGBidNativeAdManager) {
        handleLoadedCampaign(nativeAds?.first as? MTGCampaign)
    }

    func nativeAdsFailedToLoadWithError(_ error: any Error, bidNativeManager: MTGBidNativeAdManager) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    // MARK: - Waterfall 경로

    func nativeAdsLoaded(_ nativeAds: [Any]?, nativeManager: MTGNativeAdManager) {
        handleLoadedCampaign(nativeAds?.first as? MTGCampaign)
    }

    /// waterfall / bidding 공통 로드 처리
    private func handleLoadedCampaign(_ loaded: MTGCampaign?) {
        guard let campaign = loaded else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Mintegral campaign is nil")
            return
        }

        if viewBinder.isContentViewMode {
            APLogger.debug("Mintegral UnifiedNative → 매체 XIB (신규 구조)")
            guard handleNativeAdWithContentView(campaign) else { return }
            delegate?.unifiedNativeLoadSuccess()
            return
        }

        // 텍스트 바인딩
        viewBinder.titleLabel?.text = campaign.appName
        viewBinder.bodyLabel?.text = campaign.appDesc
        viewBinder.ctaButton?.setTitle(campaign.adCall, for: .normal)
        
        // 아이콘
        campaign.loadIconUrlAsync { [weak self] image in
            if let image { self?.viewBinder.iconImageView?.image = image }
        }
        
        // MediaView → mediaContainerView
        let mtgMediaView = MTGMediaView()
        self.mediaView = mtgMediaView
        mtgMediaView.delegate = self
        viewBinder.insertMediaView(mtgMediaView)
        mtgMediaView.setMediaSourceWith(campaign, unitId: unitId)

        // 옵셔널 뷰 숨김
        viewBinder.hideAllOptionalViews()
        
        // clickable views 수집 + registerView
        var clickableViews: [UIView] = []
        if let v = viewBinder.titleLabel { clickableViews.append(v) }
        if let v = viewBinder.bodyLabel { clickableViews.append(v) }
        if let v = viewBinder.ctaButton { clickableViews.append(v) }
        if let v = viewBinder.iconImageView { clickableViews.append(v) }
        clickableViews.append(mtgMediaView)
        
        if let container = viewBinder.containerView {
            if let bidLoader = bidNativeAdManager {
                bidLoader.registerView(forInteraction: container, withClickableViews: clickableViews, with: campaign)
            } else {
                nativeAdManager?.registerView(forInteraction: container, withClickableViews: clickableViews, with: campaign)
            }
        }
        
        delegate?.unifiedNativeLoadSuccess()
    }
    
    func nativeAdsFailedToLoadWithError(_ error: any Error, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeClicked(message: "Mintegral UnifiedNative clicked")
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, nativeManager: MTGNativeAdManager) {
        delegate?.unifiedNativeImpression(message: "Mintegral UnifiedNative impression")
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, mediaView: MTGMediaView) {
        delegate?.unifiedNativeClicked(message: "Mintegral UnifiedNative mediaView clicked")
    }

    /// MediaView 경유 임프레션.
    /// MediaView를 사용하는 광고는 manager delegate가 아니라 이쪽으로 impression이 전달된다.
    /// 이 메서드가 없으면 광고는 표시되지만 임프레션이 기록되지 않는다.
    func nativeAdImpression(with type: MTGAdSourceType, mediaView: MTGMediaView) {
        delegate?.unifiedNativeImpression(message: "Mintegral UnifiedNative mediaView impression")
    }

    /// bidding 경로 임프레션. (delegate 메서드가 `bidNativeManager:` 라벨로 별도 존재)
    func nativeAdImpression(with type: MTGAdSourceType, bidNativeManager: MTGBidNativeAdManager) {
        delegate?.unifiedNativeImpression(message: "Mintegral UnifiedNative bidding impression")
    }

    func nativeAdDidClick(_ nativeAd: MTGCampaign, bidNativeManager: MTGBidNativeAdManager) {
        delegate?.unifiedNativeClicked(message: "Mintegral UnifiedNative bidding clicked")
    }
}
