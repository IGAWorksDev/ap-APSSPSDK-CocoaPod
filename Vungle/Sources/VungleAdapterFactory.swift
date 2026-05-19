//
//  VungleAdapterFactory.swift
//  APSSPMediationVungle
//
//  Created by Odin on 2026/05/13.
//

import UIKit
import APSSPSDK
import VungleAdsSDK

@objc(APSSPVungleAdapterFactory)
public final class VungleAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 14 }

    public static var sdkVersion: String? { VungleInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return VungleInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return VungleBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return VungleInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return VungleRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return VungleNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return VungleVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    // MARK: - Bidding

    public static func makeBiddingBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) -> AnyObject? {
        return VungleBannerAdapter(inappbiddingPlacementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController)
    }

    public static func makeBiddingInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return VungleInterstitialVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return VungleRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return VungleNativeAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeBiddingVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return VungleVideoMixAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }
}
