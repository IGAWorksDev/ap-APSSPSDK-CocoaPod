//
//  APSSPAppLovinCustomAdapter.swift
//  MediationAppLovinMax
//
//  Created by Claude on 2026/08/20.
//

//import UIKit
//import AppLovinSDK
//import APSSPSDK
//
//
///// AppLovin MAX Custom Network Adapter for AdPopcorn SSP
///// AppLovin을 메인 미디에이션으로 사용하는 매체가 AdPopcorn 광고를 Waterfall에 포함시킬 수 있도록 한다.
///// - Android와 반대 방향: AppLovin → AdPopcorn (역방향 미디에이션)
///// - 지원 포맷: Banner, Interstitial, Reward, Native
//@objc(APSSPAppLovinCustomAdapter)
//final public class APSSPAppLovinCustomAdapter: ALMediationAdapter, MAAdViewAdapter, MAInterstitialAdapter, MARewardedAdapter, MANativeAdAdapter {
//
//    // MARK: - Properties
//
//    // Banner
//    private var bannerCustomAd: APSSPCustomAd?
//    private weak var adViewDelegate: MAAdViewAdapterDelegate?
//    private var bannerView: UIView?
//
//    // Interstitial
//    private var interstitialAd: APSSPInterstitialAd?
//    private weak var interstitialDelegate: MAInterstitialAdapterDelegate?
//
//    // Reward
//    private var rewardVideoAd: APSSPRewardVideoAd?
//    private weak var rewardedDelegate: MARewardedAdapterDelegate?
//    private var isRewardEarned = false
//
//    // Native
//    private var nativeCustomAd: APSSPCustomAd?
//    private weak var nativeDelegate: MANativeAdAdapterDelegate?
//    private var landingUrl: String?
//
//
//    // MARK: - Initialization
//
//    public override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping (MAAdapterInitializationStatus, String?) -> Void) {
//
//        // GDPR 동의 처리는 AppLovin이 자동으로 함
//        // 우리 SDK 초기화만 확인
//        APLogger.debug("APSSPAppLovinCustomAdapter initialize")
//
//        // 간단히 성공 처리 (APSSPSDK는 매체가 먼저 초기화했을 것)
//        completionHandler(.doesNotApply, nil)
//    }
//
//    public override var sdkVersion: String {
//        return "3.3.0"
//    }
//
//    public override var adapterVersion: String {
//        return "3.3.0.0"
//    }
//
//    public override func destroy() {
//        // Banner
//        bannerCustomAd?.stopAd()
//        bannerCustomAd = nil
//        bannerView = nil
//        adViewDelegate = nil
//
//        // Interstitial
//        interstitialAd = nil
//        interstitialDelegate = nil
//
//        // Reward
//        rewardVideoAd = nil
//        rewardedDelegate = nil
//
//        // Native
//        nativeCustomAd?.stopAd()
//        nativeCustomAd = nil
//        nativeDelegate = nil
//    }
//
//
//    // MARK: - MAAdViewAdapter (Banner)
//
//    public func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate) {
//
//        let placementId = parameters.thirdPartyAdPlacementIdentifier
//        guard let appKey = parameters.serverParameters["appKey"] as? String, !appKey.isEmpty else {
//            delegate.didFailToLoadAdViewAd(with: MAAdapterError.invalidConfiguration)
//            return
//        }
//
//        let adSizeValue = parameters.serverParameters["adSize"] as? Int ?? 0
//        let adType = convertAdSize(adSizeValue)
//
//        APLogger.debug("APSSPAppLovinCustomAdapter loadAdView - appKey: \(appKey), placementId: \(placementId), adType: \(adType.rawValue)")
//
//        adViewDelegate = delegate
//
//        bannerCustomAd = APSSPCustomAd(appKey: appKey, placementId: placementId, adType: adType)
//        bannerCustomAd?.delegate = self
//        bannerCustomAd?.loadAd()
//    }
//
//    private func convertAdSize(_ adSizeValue: Int) -> APSSPCustomAdType {
//        switch adSizeValue {
//        case 0:
//            return .banner320x50
//        case 1:
//            return .banner300x250
//        case 2:
//            return .banner320x100
//        default:
//            return .banner320x50
//        }
//    }
//
//
//    // MARK: - MAInterstitialAdapter
//
//    public func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate) {
//
//        let placementId = parameters.thirdPartyAdPlacementIdentifier
//        guard let appKey = parameters.serverParameters["appKey"] as? String, !appKey.isEmpty else {
//            delegate.didFailToLoadInterstitialAd(with: MAAdapterError.invalidConfiguration)
//            return
//        }
//
//        APLogger.debug("APSSPAppLovinCustomAdapter loadInterstitialAd - appKey: \(appKey), placementId: \(placementId)")
//
//        interstitialDelegate = delegate
//
//        interstitialAd = APSSPInterstitialAd(appKey: appKey, placementId: placementId)
//        interstitialAd?.delegate = self
//        interstitialAd?.load()
//    }
//
//    public func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate) {
//
//        APLogger.debug("APSSPAppLovinCustomAdapter showInterstitialAd")
//
//        guard let interstitialAd = interstitialAd else {
//            delegate.didFailToDisplayInterstitialAdWithError(MAAdapterError.adNotReady)
//            return
//        }
//
//        guard let rootViewController = getRootViewController() else {
//            delegate.didFailToDisplayInterstitialAdWithError(MAAdapterError.noViewController)
//            return
//        }
//
//        interstitialAd.present(from: rootViewController)
//    }
//
//
//    // MARK: - MARewardedAdapter
//
//    public func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate) {
//
//        let placementId = parameters.thirdPartyAdPlacementIdentifier
//        guard let appKey = parameters.serverParameters["appKey"] as? String, !appKey.isEmpty else {
//            delegate.didFailToLoadRewardedAdWithError(MAAdapterError.invalidConfiguration)
//            return
//        }
//
//        APLogger.debug("APSSPAppLovinCustomAdapter loadRewardedAd - appKey: \(appKey), placementId: \(placementId)")
//
//        rewardedDelegate = delegate
//        isRewardEarned = false
//
//        rewardVideoAd = APSSPRewardVideoAd(appKey: appKey, placementId: placementId)
//        rewardVideoAd?.delegate = self
//        rewardVideoAd?.load()
//    }
//
//    public func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate) {
//
//        APLogger.debug("APSSPAppLovinCustomAdapter showRewardedAd")
//
//        guard let rewardVideoAd = rewardVideoAd, rewardVideoAd.isReady else {
//            delegate.didFailToDisplayRewardedAdWithError(MAAdapterError.adNotReady)
//            return
//        }
//
//        guard let rootViewController = getRootViewController() else {
//            delegate.didFailToDisplayRewardedAdWithError(MAAdapterError.noViewController)
//            return
//        }
//
//        rewardVideoAd.present(from: rootViewController)
//    }
//
//
//    // MARK: - MANativeAdAdapter
//
//    public func loadNativeAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MANativeAdAdapterDelegate) {
//
//        let placementId = parameters.thirdPartyAdPlacementIdentifier
//        guard let appKey = parameters.serverParameters["appKey"] as? String, !appKey.isEmpty else {
//            delegate.didFailToLoadNativeAd(with: MAAdapterError.invalidConfiguration)
//            return
//        }
//
//        APLogger.debug("APSSPAppLovinCustomAdapter loadNativeAd - appKey: \(appKey), placementId: \(placementId)")
//
//        nativeDelegate = delegate
//
//        nativeCustomAd = APSSPCustomAd(appKey: appKey, placementId: placementId, adType: .nativeAd)
//        nativeCustomAd?.delegate = self
//        nativeCustomAd?.loadAd()
//    }
//
//
//    // MARK: - Error Conversion
//
//    private func convertToMaxError(_ error: APSSPNetworkError) -> MAAdapterError {
//        switch error.code {
//        case .noAd:
//            return .noFill
//        case .timeout:
//            return .timeout
//        case .invalidPlacementId, .invalidAppKey:
//            return .invalidConfiguration
//        case .serverError:
//            return .serverError
//        case .networkError:
//            return .noConnection
//        default:
//            return .unspecified
//        }
//    }
//
//    // MARK: - Helper
//
//    private func getRootViewController() -> UIViewController? {
//        if #available(iOS 13.0, *) {
//            return UIApplication.shared.connectedScenes
//                .compactMap { $0 as? UIWindowScene }
//                .flatMap { $0.windows }
//                .first { $0.isKeyWindow }?
//                .rootViewController
//        } else {
//            return UIApplication.shared.keyWindow?.rootViewController
//        }
//    }
//}
//
//
//// MARK: - APSSPCustomAdDelegate (Banner, Native)
//
//extension APSSPAppLovinCustomAdapter: APSSPCustomAdDelegate {
//
//    public func apsspCustomAdLoadSuccess(_ customAd: APSSPCustomAd, adData: String) {
//
//        // Banner
//        if customAd === bannerCustomAd {
//            APLogger.debug("APSSPAppLovinCustomAdapter Banner LoadSuccess")
//
//            // Banner는 CustomAd를 View로 표시
//            // 하지만 APSSPCustomAd는 JSON만 제공하므로 실제로는 별도 BannerAd 필요
//            // 여기서는 간단히 빈 View 리턴 (실제로는 APSSPBannerAd 사용 권장)
//            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//            emptyView.backgroundColor = .clear
//            self.bannerView = emptyView
//            adViewDelegate?.didLoadAd(for: emptyView)
//            return
//        }
//
//        // Native
//        if customAd === nativeCustomAd {
//            APLogger.debug("APSSPAppLovinCustomAdapter Native LoadSuccess")
//
//            guard let data = adData.data(using: .utf8),
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                nativeDelegate?.didFailToLoadNativeAd(with: MAAdapterError.invalidLoadState)
//                return
//            }
//
//            let title = json["Title"] as? String ?? ""
//            let body = json["Desc"] as? String ?? ""
//            let ctaText = json["CtaText"] as? String ?? ""
//            let iconUrl = json["IconImageURL"] as? String ?? ""
//            let mainImageUrl = json["MainImageURL"] as? String ?? ""
//            landingUrl = json["LandingURL"] as? String
//
//            // 이미지 다운로드 (백그라운드)
//            DispatchQueue.global().async { [weak self] in
//                guard let self = self else { return }
//
//                let iconImage = self.downloadImage(from: iconUrl)
//                let mainImage = self.downloadImage(from: mainImageUrl)
//
//                DispatchQueue.main.async {
//                    let builder = MANativeAdBuilder()
//                    builder.withTitle(title)
//                    builder.withBody(body)
//                    builder.withCallToAction(ctaText)
//
//                    if let icon = iconImage {
//                        builder.withIcon(MANativeAdImage(image: icon))
//                    }
//
//                    if let main = mainImage {
//                        let mediaView = UIImageView(image: main)
//                        mediaView.contentMode = .scaleAspectFit
//                        builder.withMediaView(mediaView)
//                    }
//
//                    let nativeAd = APSSPMaxNativeAd(builder: builder, adapter: self)
//                    self.nativeDelegate?.didLoadAd(for: nativeAd, withExtraInfo: nil)
//                }
//            }
//        }
//    }
//
//    public func apsspCustomAdLoadFail(_ customAd: APSSPCustomAd, error: APSSPNetworkError) {
//        if customAd === bannerCustomAd {
//            APLogger.error("APSSPAppLovinCustomAdapter Banner LoadFail: \(error.localizedDescription)")
//            adViewDelegate?.didFailToLoadAdViewAd(with: convertToMaxError(error))
//        }
//
//        if customAd === nativeCustomAd {
//            APLogger.error("APSSPAppLovinCustomAdapter Native LoadFail: \(error.localizedDescription)")
//            nativeDelegate?.didFailToLoadNativeAd(with: convertToMaxError(error))
//        }
//    }
//
//    private func downloadImage(from urlString: String) -> UIImage? {
//        guard !urlString.isEmpty,
//              let url = URL(string: urlString),
//              let data = try? Data(contentsOf: url),
//              let image = UIImage(data: data) else {
//            return nil
//        }
//        return image
//    }
//}
//
//
//// MARK: - APSSPInterstitialAdDelegate
//
//extension APSSPAppLovinCustomAdapter: APSSPInterstitialAdDelegate {
//
//    public func apsspInterstitialAdLoadSuccess(interstitialAd: APSSPInterstitialAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Interstitial LoadSuccess")
//        interstitialDelegate?.didLoadInterstitialAd()
//    }
//
//    public func apsspInterstitialAdLoadFail(interstitialAd: APSSPInterstitialAd, error: APSSPNetworkError) {
//        APLogger.error("APSSPAppLovinCustomAdapter Interstitial LoadFail: \(error.localizedDescription)")
//        interstitialDelegate?.didFailToLoadInterstitialAdWithError(convertToMaxError(error))
//    }
//
//    public func apsspInterstitialAdShowSuccess(interstitialAd: APSSPInterstitialAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Interstitial ShowSuccess")
//        interstitialDelegate?.didDisplayInterstitialAd()
//    }
//
//    public func apsspInterstitialAdShowFail(interstitialAd: APSSPInterstitialAd, error: APSSPNetworkError) {
//        APLogger.error("APSSPAppLovinCustomAdapter Interstitial ShowFail")
//        interstitialDelegate?.didFailToDisplayInterstitialAdWithError(MAAdapterError.adDisplayFailed)
//    }
//
//    public func apsspInterstitialAdClicked(interstitialAd: APSSPInterstitialAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Interstitial Clicked")
//        interstitialDelegate?.didClickInterstitialAd()
//    }
//
//    public func apsspInterstitialAdClosed(interstitialAd: APSSPInterstitialAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Interstitial Closed")
//        interstitialDelegate?.didHideInterstitialAd()
//    }
//}
//
//
//// MARK: - APSSPRewardVideoAdDelegate
//
//extension APSSPAppLovinCustomAdapter: APSSPRewardVideoAdDelegate {
//
//    public func apsspRewardVideoAdLoadSuccess(rewardVideoAd: APSSPRewardVideoAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Reward LoadSuccess")
//        rewardedDelegate?.didLoadRewardedAd()
//    }
//
//    public func apsspRewardVideoAdLoadFail(rewardVideoAd: APSSPRewardVideoAd, error: APSSPNetworkError) {
//        APLogger.error("APSSPAppLovinCustomAdapter Reward LoadFail: \(error.localizedDescription)")
//        rewardedDelegate?.didFailToLoadRewardedAdWithError(convertToMaxError(error))
//    }
//
//    public func apsspRewardVideoAdShowSuccess(rewardVideoAd: APSSPRewardVideoAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Reward ShowSuccess")
//        rewardedDelegate?.didDisplayRewardedAd()
//    }
//
//    public func apsspRewardVideoAdShowFail(rewardVideoAd: APSSPRewardVideoAd, error: APSSPNetworkError) {
//        APLogger.error("APSSPAppLovinCustomAdapter Reward ShowFail")
//        rewardedDelegate?.didFailToDisplayRewardedAdWithError(MAAdapterError.adDisplayFailed)
//    }
//
//    public func apsspRewardVideoAdClicked(rewardVideoAd: APSSPRewardVideoAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Reward Clicked")
//        rewardedDelegate?.didClickRewardedAd()
//    }
//
//    public func apsspRewardVideoAdClosed(rewardVideoAd: APSSPRewardVideoAd) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Reward Closed")
//
//        if isRewardEarned {
//            let reward = MAReward.create(withAmount: 1, label: "")
//            rewardedDelegate?.didRewardUser(with: reward)
//        }
//
//        rewardedDelegate?.didHideRewardedAd()
//    }
//
//    public func apsspRewardVideoAdPlayCompleted(rewardVideoAd: APSSPRewardVideoAd, adNetworkNo: Int, completed: Bool) {
//        APLogger.debug("APSSPAppLovinCustomAdapter Reward Completed")
//        if completed {
//            isRewardEarned = true
//        }
//    }
//}
//
//
//// MARK: - Custom MANativeAd
//
//private class APSSPMaxNativeAd: MANativeAd {
//
//    weak var adapter: APSSPAppLovinCustomAdapter?
//
//    init(builder: MANativeAdBuilder, adapter: APSSPAppLovinCustomAdapter) {
//        self.adapter = adapter
//        super.init(format: .native, builderBlock: builder.builderBlock)
//    }
//
//    override func prepare(forInteractionClickableViews clickableViews: [UIView]?, withContainer container: UIView) -> Bool {
//
//        guard let customAd = adapter?.nativeCustomAd else { return false }
//
//        APLogger.debug("APSSPMaxNativeAd prepareForInteraction")
//
//        // Impression 추적 (간단한 delay 방식)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            customAd.reportImpression()
//            self?.adapter?.nativeDelegate?.didDisplayNativeAd(withExtraInfo: nil)
//        }
//
//        // Click 리스너 등록
//        clickableViews?.forEach { view in
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleClick))
//            view.addGestureRecognizer(tapGesture)
//            view.isUserInteractionEnabled = true
//        }
//
//        return true
//    }
//
//    @objc func handleClick() {
//        adapter?.nativeCustomAd?.reportClick()
//        adapter?.nativeDelegate?.didClickNativeAd()
//
//        // 랜딩 페이지 열기
//        if let urlString = adapter?.landingUrl,
//           let url = URL(string: urlString) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
