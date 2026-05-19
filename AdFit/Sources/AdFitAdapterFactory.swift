import UIKit
import APSSPSDK
import AdFitSDK

@objc(APSSPAdFitAdapterFactory)
public final class AdFitAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 10 }

    public static var sdkVersion: String? { AdFitInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return AdFitInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return AdFitBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return AdFitNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }
}
