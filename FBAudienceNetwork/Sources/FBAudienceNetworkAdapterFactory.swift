import UIKit
import APSSPSDK

@objc(APSSPFBAudienceNetworkAdapterFactory)
public final class FBAudienceNetworkAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 2 }

    public static var sdkVersion: String? { FBAudienceNetworkInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return FBAudienceNetworkInitializationAdapter()
    }

    // MARK: - 일반 (Banner, Native, VideoMix는 bidding init 없음)

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FBAudienceNetworkBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return FBAudienceNetworkNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FBAudienceNetworkVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    // MARK: - Bidding (IS, IV, RV만 bidding init 지원)

    public static func makeBiddingInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FBAudienceNetworkInterstitialAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FBAudienceNetworkInterstitialVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FBAudienceNetworkRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }
}
