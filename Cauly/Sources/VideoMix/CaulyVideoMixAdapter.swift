//
//  CaulyVideoMixAdapter.swift
//  MediationCauly
//

import UIKit
import APSSPSDK

final public class CaulyVideoMixAdapter: APSSPVideoMixAdAdapterProtocol {
    public var rootViewController: UIViewController?
    public var videoMixDelegate: APSSPVideoMixAdAdapterDelegate?
    public var videoMixAdType: APSSPVideoMixAdType = .RewardVideo
    private var placementDic: [String: String] = [:]
    private var interstitialAdapter: CaulyInterstitialAdapter?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        self.placementDic = placementDic; self.rootViewController = rootViewController
        if let ct = placementDic[APSSPPlacementKey.campaignType.rawValue], let v = Int(ct), let t = APSSPVideoMixAdType(rawValue: v) { videoMixAdType = t }
    }

    public func connectVideoMixDelegate(delegate: APSSPVideoMixAdAdapterDelegate) {
        videoMixDelegate = delegate
        switch videoMixAdType {
        case .Interstitial:
            interstitialAdapter = CaulyInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            interstitialAdapter?.connectDelegate(delegate: self)
        case .InterstitialVideo, .RewardVideo:
            videoMixDelegate?.videoMixAdLoadFail(error: .noAdError, type: videoMixAdType, errorMessage: "Ad type not supported")
        @unknown default:
            break
        }
    }

    public func disconnectVideoMixDelegate() {
        interstitialAdapter = nil
        videoMixDelegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        switch videoMixAdType {
        case .Interstitial: interstitialAdapter?.present(from: from) { completion() }
        case .InterstitialVideo, .RewardVideo: break
        @unknown default:
            break
        }
    }
}

extension CaulyVideoMixAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func interstitialShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func interstitialShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func interstitialClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func interstitialClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
}
