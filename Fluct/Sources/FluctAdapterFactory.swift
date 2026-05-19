import UIKit
import APSSPSDK
import FluctSDK

@objc(APSSPFluctAdapterFactory)
public final class FluctAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 41 }

    public static var sdkVersion: String? { FluctInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return FluctInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FluctBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FluctInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FluctRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
