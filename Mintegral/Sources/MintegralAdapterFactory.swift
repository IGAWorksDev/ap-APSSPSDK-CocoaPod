import UIKit
import APSSPSDK
import MTGSDK

@objc(APSSPMintegralAdapterFactory)
public final class MintegralAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 8 }

    public static var sdkVersion: String? { MintegralInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return MintegralInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MintegralBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MintegralInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MintegralRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return MintegralNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }
}
