//
//  GAMVideoMixAdapter.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit

import APSSPSDK


final public class GAMVideoMixAdapter: APSSPVideoMixAdAdapterProtocol {
    
    public var rootViewController: UIViewController?
    
    public var videoMixDelegate: APSSPVideoMixAdAdapterDelegate?
    
    public var videoMixAdType: APSSPVideoMixAdType = .RewardVideo
    
    private var placementDic: [String: String] = [:]
    
    private var interstitialAdapter: GAMInterstitialAdapter?
    private var interstitialVideoAdapter: GAMInterstitialVideoAdapter?
    private var rewardVideoAdapter: GAMRewardVideoAdapter?
    
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        self.placementDic = placementDic
        self.rootViewController = rootViewController
        
        if let campaignType = placementDic[APSSPPlacementKey.campaignType.rawValue], let value = Int(campaignType),
           let type = APSSPVideoMixAdType(rawValue: value) {
            self.videoMixAdType = type
        }
    }
    
    public func connectVideoMixDelegate(delegate: APSSPVideoMixAdAdapterDelegate) {
        self.videoMixDelegate = delegate
        
        switch videoMixAdType {
        case .Interstitial:
            interstitialAdapter = GAMInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            interstitialAdapter?.connectDelegate(delegate: self)
            
        case .InterstitialVideo:
            interstitialVideoAdapter = GAMInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            interstitialVideoAdapter?.connectDelegate(delegate: self)
            
        case .RewardVideo:
            rewardVideoAdapter = GAMRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            rewardVideoAdapter?.connectDelegate(delegate: self)
        @unknown default:
            break
        }
    }
    
    public func disconnectVideoMixDelegate() {
        interstitialAdapter = nil
        interstitialVideoAdapter = nil
        rewardVideoAdapter = nil
        videoMixDelegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        switch videoMixAdType {
        case .Interstitial:
            interstitialAdapter?.present(from: from) { completion() }
        case .InterstitialVideo:
            interstitialVideoAdapter?.present(from: from) { completion() }
        case .RewardVideo:
            rewardVideoAdapter?.present(from: from) { completion() }
        @unknown default:
            break
        }
    }
}


// MARK: - APSSPInterstitialAdapterDelegate
extension GAMVideoMixAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() {
        videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType)
    }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage)
    }
    public func interstitialShowSuccess(message: String) {
        videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType)
    }
    public func interstitialShowFail(message: String) {
        videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType)
    }
    public func interstitialClicked(message: String) {
        videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType)
    }
    public func interstitialClosed(message: String) {
        videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType)
    }
}


// MARK: - APSSPInterstitialVideoAdapterDelegate
extension GAMVideoMixAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadSuccess() {
        videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType)
    }
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage)
    }
    public func interstitialVideoShowSuccess(message: String) {
        videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType)
    }
    public func interstitialVideoShowFail(message: String) {
        videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType)
    }
    public func interstitialVideoClicked(message: String) {
        videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType)
    }
    public func interstitialVideoClosed(message: String) {
        videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType)
    }
}


// MARK: - APSSPRewardVideoAdapterDelegate
extension GAMVideoMixAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() {
        videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType)
    }
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage)
    }
    public func rewardVideoShowSuccess(message: String) {
        videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType)
    }
    public func rewardVideoShowFail(message: String) {
        videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType)
    }
    public func rewardVideoClicked(message: String) {
        videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType)
    }
    public func rewardVideoClosed(message: String) {
        videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType)
    }
    public func rewardVideoCompleted() {
        videoMixDelegate?.videoMixAdCompleteTrackingEvent(adNetworkNo: 19, isCompleted: true, type: videoMixAdType)
    }
}
