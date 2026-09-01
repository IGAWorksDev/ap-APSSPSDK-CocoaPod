import UIKit
import APSSPSDK
import UnityAds

@objc(APSSPUnityAdsAdapterFactory)
public final class UnityAdsAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 7 }

    public static var sdkVersion: String? { UnityAdsInitializationAdpater().sdkVersion }
    public static var adapterVersion: String? { "4.17.0.13" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return UnityAdsInitializationAdpater()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return UnityAdsBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return UnityAdsInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return UnityAdsInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return UnityAdsRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return UnityAdsVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    // MARK: - Bidding

    public static func makeBiddingBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) -> AnyObject? {
        return UnityAdsBannerAdapter(inappbiddingPlacementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController)
    }

    public static func makeBiddingInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return UnityAdsInterstitialAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return UnityAdsRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return UnityAdsVideoMixAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }
}
