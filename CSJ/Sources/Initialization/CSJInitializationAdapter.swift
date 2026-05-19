import Foundation
import APSSPSDK
import BUAdSDK

public final class CSJInitializationAdapter: APSSPInitializationProtocol {
    public init() { }

    public var sdkVersion: String? { BUAdSDKManager.sdkVersion }

    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appId = keys[APSSPInitKey.csjAppId.key], !appId.isEmpty else {
            completion(false, "CSJAppId is nil")
            return
        }
        let config = BUAdSDKConfiguration.configuration()
        config.appID = appId
        BUAdSDKManager.start(syncCompletionHandler: { success, error in
            completion(success, error?.localizedDescription)
        })
    }
}
