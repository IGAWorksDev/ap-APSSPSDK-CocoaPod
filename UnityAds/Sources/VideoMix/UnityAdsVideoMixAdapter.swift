//
//  UnityAdsVideoMixAdapter.swift
//  MediationUnityAds
//

import UIKit
import APSSPSDK
import UnityAds

final public class UnityAdsVideoMixAdapter: APSSPVideoMixAdAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?
    public var videoMixDelegate: APSSPVideoMixAdAdapterDelegate?
    public var videoMixAdType: APSSPVideoMixAdType = .RewardVideo
    private var placementDic: [String: String] = [:]
    private var interstitialAdapter: UnityAdsInterstitialAdapter?
    private var interstitialVideoAdapter: UnityAdsInterstitialVideoAdapter?
    private var rewardVideoAdapter: UnityAdsRewardVideoAdapter?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        self.placementDic = placementDic; self.rootViewController = rootViewController
        if let ct = placementDic[APSSPPlacementKey.campaignType.rawValue], let v = Int(ct), let t = APSSPVideoMixAdType(rawValue: v) { videoMixAdType = t }
    }

    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        self.placementDic = inappbiddingPlacementDic; self.rootViewController = rootViewController
        if let ct = inappbiddingPlacementDic[APSSPPlacementKey.campaignType.rawValue], let v = Int(ct), let t = APSSPVideoMixAdType(rawValue: v) { videoMixAdType = t }
    }

    public func connectVideoMixDelegate(delegate: APSSPVideoMixAdAdapterDelegate) {
        videoMixDelegate = delegate
        let isBidding = placementDic[APSSPBiddingKey.biddingData.rawValue] != nil
        switch videoMixAdType {
        case .Interstitial:
            if isBidding {
                interstitialAdapter = UnityAdsInterstitialAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
            } else {
                interstitialAdapter = UnityAdsInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            }
            interstitialAdapter?.connectDelegate(delegate: self)
        case .InterstitialVideo:
            interstitialVideoAdapter = UnityAdsInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            interstitialVideoAdapter?.connectDelegate(delegate: self)
        case .RewardVideo:
            if isBidding {
                rewardVideoAdapter = UnityAdsRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
            } else {
                rewardVideoAdapter = UnityAdsRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            }
            rewardVideoAdapter?.connectDelegate(delegate: self)
        @unknown default:
            break
        }
    }

    public func disconnectVideoMixDelegate() { interstitialAdapter = nil; interstitialVideoAdapter = nil; rewardVideoAdapter = nil; videoMixDelegate = nil }
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        switch videoMixAdType {
        case .Interstitial: interstitialAdapter?.present(from: from) { completion() }
        case .InterstitialVideo: interstitialVideoAdapter?.present(from: from) { completion() }
        case .RewardVideo: rewardVideoAdapter?.present(from: from) { completion() }
        @unknown default:
            break
        }
    }
    
    public func getBiddingToken() -> String {
        return UnityAds.getToken() ?? ""
    }
}

extension UnityAdsVideoMixAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func interstitialShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func interstitialShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func interstitialClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func interstitialClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
}

extension UnityAdsVideoMixAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func interstitialVideoShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func interstitialVideoShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func interstitialVideoClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func interstitialVideoClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
}

extension UnityAdsVideoMixAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func rewardVideoShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func rewardVideoShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func rewardVideoClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func rewardVideoClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
    public func rewardVideoCompleted() { videoMixDelegate?.videoMixAdCompleteTrackingEvent(adNetworkNo: APSSPMediationCompany.UnityAds.rawValue, isCompleted: true, type: videoMixAdType) }
}
