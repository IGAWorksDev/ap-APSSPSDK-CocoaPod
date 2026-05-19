import Foundation
import APSSPSDK
import GoogleMobileAds

public final class GAMInitializationAdapter: APSSPInitializationProtocol {
    private static var isInitialized = false
    public init() { }
    public var sdkVersion: String? {
        let v = MobileAds.shared.versionNumber
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard !Self.isInitialized else {
            completion(true, nil)
            return
        }
        Self.isInitialized = true
        MobileAds.shared.start { _ in
            completion(true, nil)
        }
    }
}
