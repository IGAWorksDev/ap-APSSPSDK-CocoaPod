import UIKit
import APSSPSDK
import CaulySDK

@objc(APSSPCaulyAdapterFactory)
public final class CaulyAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 4 }

    public static var sdkVersion: String? { CaulyInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return CaulyInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return CaulyBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return CaulyInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return CaulyVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
