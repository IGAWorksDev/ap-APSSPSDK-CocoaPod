import UIKit
import APSSPSDK
import UnityAds

@objc(APSSPUnityAdsAdapterFactory)
public final class UnityAdsAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 7 }

    public static var sdkVersion: String? { UnityAdsInitializationAdpater().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return UnityAdsInitializationAdpater()
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
}
