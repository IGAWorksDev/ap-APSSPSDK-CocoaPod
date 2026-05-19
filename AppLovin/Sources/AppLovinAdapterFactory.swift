//
//  AppLovinAdapterFactory.swift
//  APSSPMediationAppLovin
//
//  Created by Odin on 2026/05/13.
//

import UIKit
import APSSPSDK
import AppLovinSDK

@objc(APSSPAppLovinAdapterFactory)
public final class AppLovinAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 15 }

    public static var sdkVersion: String? { AppLovinInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return AppLovinInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AppLovinVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
