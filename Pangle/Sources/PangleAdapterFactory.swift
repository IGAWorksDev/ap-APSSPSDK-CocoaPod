import UIKit
import APSSPSDK
import PAGAdSDK

@objc(APSSPPangleAdapterFactory)
public final class PangleAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 18 }

    public static var sdkVersion: String? { PangleInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return PangleInitializationAdapter()
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return PangleAdsInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return PangleRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return PangleVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    // MARK: - Bidding

    public static func makeBiddingInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return PangleAdsInterstitialVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return PangleRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return PangleVideoMixAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }
}
