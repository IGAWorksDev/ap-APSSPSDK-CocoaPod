import UIKit
import APSSPSDK

@objc(APSSPADOPAdapterFactory)
public final class ADOPAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 24 }
    public static var sdkVersion: String? { ADOPInitializationAdapter().sdkVersion }
    public static var adapterVersion: String? { "13.5.0.1" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return ADOPInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return ADOPBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return ADOPInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return ADOPInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return ADOPRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return ADOPNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return ADOPVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeUnifiedNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, info: [String: Any]) -> AnyObject? {
        return ADOPUnifiedNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, viewBinder: viewBinder, config: config, info: info)
    }
}
