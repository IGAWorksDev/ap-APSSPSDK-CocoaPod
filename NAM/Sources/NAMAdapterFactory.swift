import UIKit
import APSSPSDK
import GFPSDK

@objc(APSSPNAMAdapterFactory)
public final class NAMAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 22 }

    public static var sdkVersion: String? { NAMInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return NAMInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return NAMBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return NAMNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeModalAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return NAMModalAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
