//
//  FBAudienceNetworkNativeAdapter.swift
//  MediationFBAudienceNetwork
//
//  Created by Odin.송황호 on 2023/09/15.
//

import UIKit
import FBAudienceNetwork
import APSSPSDK


final public class FBAudienceNetworkNativeAdapter: APSSPNativeAdapterInappBiddingProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var nativeAdView: FBAudienceNetworkMediationNativeAdView
    
    
    // MARK: - Waterfall 초기화

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fbPlacementId.rawValue] ?? ""
        let isNativeBanner: Bool? = info[APSSPAdapterInfo.isNativeBanner.rawValue] as? Bool
        let biddingData: String = info[APSSPAdapterInfo.FBbiddingData.rawValue] as? String ?? ""
        
        self.nativeAdView = FBAudienceNetworkMediationNativeAdView(placementId: placementId,
                                                                   biddingData: biddingData,
                                                                   rootViewController: rootViewController,
                                                                   render: render,
                                                                   isNativeBanner: isNativeBanner)
        nativeAdView.delegate = self
    }
    
    // MARK: - InApp Bidding 초기화
    
    public required init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any?]) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.facebookPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        
        self.nativeAdView = FBAudienceNetworkMediationNativeAdView(placementId: placementId,
                                                                   biddingData: biddingData,
                                                                   rootViewController: rootViewController,
                                                                   render: render,
                                                                   isNativeBanner: nil)
        nativeAdView.delegate = self
    }
    
    // MARK: - Bidding Token
    
    public func getBiddingToken() -> String {
        return FBAdSettings.bidderToken
    }

    // MARK: - Protocol Methods
    
    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        nativeAdView.delegate = self
        nativeAdView.load()
    }

    public func disconnectDelegate() {
        nativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() {
        nativeAdView.stop()
    }
}


extension FBAudienceNetworkNativeAdapter: APSSPNativeViewAdapterDelegate {
    public func nativeLoadSuccess() {
        delegate?.nativeLoadSuccess()
    }
    
    public func nativeLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.nativeLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func nativeClicked(message: String) {
        delegate?.nativeClicked(message: message)
    }
    
    public func nativeImpression(message: String) {
        delegate?.nativeImpression(message: message)
    }
}
