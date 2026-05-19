//
//  VungleVideoMixAdapter.swift
//  MediationVungle
//

import UIKit
import APSSPSDK

final public class VungleVideoMixAdapter: APSSPVideoMixAdAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?
    public var videoMixDelegate: APSSPVideoMixAdAdapterDelegate?
    public var videoMixAdType: APSSPVideoMixAdType = .RewardVideo
    private var placementDic: [String: String] = [:]
    private var interstitialVideoAdapter: VungleInterstitialVideoAdapter?
    private var rewardVideoAdapter: VungleRewardVideoAdapter?

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
        switch videoMixAdType {
        case .Interstitial:
            videoMixDelegate?.videoMixAdLoadFail(error: .noAdError, type: videoMixAdType, errorMessage: "Ad type not supported")
        case .InterstitialVideo:
            interstitialVideoAdapter = VungleInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            interstitialVideoAdapter?.connectDelegate(delegate: self)
        case .RewardVideo:
            rewardVideoAdapter = VungleRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            rewardVideoAdapter?.connectDelegate(delegate: self)
        @unknown default:
            break
        }
    }

    public func disconnectVideoMixDelegate() { interstitialVideoAdapter = nil; rewardVideoAdapter = nil; videoMixDelegate = nil }
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        switch videoMixAdType {
        case .Interstitial: break
        case .InterstitialVideo: interstitialVideoAdapter?.present(from: from) { completion() }
        case .RewardVideo: rewardVideoAdapter?.present(from: from) { completion() }
        @unknown default:
            break
        }
    }
    
    public func getBiddingToken() -> String {
        return interstitialVideoAdapter?.getBiddingToken() ?? rewardVideoAdapter?.getBiddingToken() ?? ""
    }
}

extension VungleVideoMixAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func interstitialVideoShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func interstitialVideoShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func interstitialVideoClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func interstitialVideoClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
}

extension VungleVideoMixAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func rewardVideoShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func rewardVideoShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func rewardVideoClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func rewardVideoClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
    public func rewardVideoCompleted() { videoMixDelegate?.videoMixAdCompleteTrackingEvent(adNetworkNo: APSSPMediationCompany.Vungle.rawValue, isCompleted: true, type: videoMixAdType) }
}
