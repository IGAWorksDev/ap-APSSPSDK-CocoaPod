import UIKit
import APSSPSDK
import Maio

@objc(APSSPMaioAdapterFactory)
public final class MaioAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 39 }

    public static var sdkVersion: String? { MaioInitializationAdapter().sdkVersion }
    public static var adapterVersion: String? { "2.2.1.11" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return MaioInitializationAdapter()
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MaioInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return MaioRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }
}
