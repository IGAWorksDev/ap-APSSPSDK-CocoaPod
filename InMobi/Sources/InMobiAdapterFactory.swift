import UIKit
import APSSPSDK
import InMobiSDK

@objc(APSSPInMobiAdapterFactory)
public final class InMobiAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 37 }

    public static var sdkVersion: String? { InMobiInitializationAdapter().sdkVersion }
    public static var adapterVersion: String? { "11.2.0.10" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return InMobiInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return InMobiBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return InMobiInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return InMobiInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return InMobiRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return InMobiNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return InMobiVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeUnifiedNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, info: [String: Any]) -> AnyObject? {
        return InMobiUnifiedNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, viewBinder: viewBinder, config: config, info: info)
    }
}
