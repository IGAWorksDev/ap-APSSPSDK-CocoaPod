import UIKit
import APSSPSDK
import LibADPlus

@objc(APSSPMezzoAdapterFactory)
public final class MezzoAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 5 }

    public static var sdkVersion: String? { MezzoInitializationAdapter().sdkVersion }

    public static func makeInitializationAdapter() -> AnyObject? {
        return MezzoInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MezzoBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }
}
