//
//  AppLovinMaxAdapterFactory.swift
//  APSSPMediationAppLovinMax
//
//  Created by Odin on 2026/05/13.
//

import UIKit
import APSSPSDK
import AppLovinSDK

@objc(APSSPAppLovinMaxAdapterFactory)
public final class AppLovinMaxAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 23 }

    public static var sdkVersion: String? { AppLovinMaxInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return AppLovinMaxInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinMaxVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
