import UIKit
import APSSPSDK

@objc(APSSPAdMobAdapterFactory)
public final class AdMobAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 1 }
    public static var sdkVersion: String? { AdMobInitializationAdapter().sdkVersion }
    public static var adapterVersion: String? { "13.5.0.1" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return AdMobInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdMobBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdMobInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdMobInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdMobRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return AdMobNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeUnifiedNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, info: [String: Any]) -> AnyObject? {
        return AdMobUnifiedNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, viewBinder: viewBinder, config: config, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdMobVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
