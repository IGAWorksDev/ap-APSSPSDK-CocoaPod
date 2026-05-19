import Foundation
import APSSPSDK
import LibADPlus

public final class MezzoInitializationAdapter: APSSPInitializationProtocol {
    public init() { }
    public var sdkVersion: String? {
        let version = LibADPlusVersionNumber
        return version > 0 ? String(format: "%.1f", version) : nil
    }
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) { completion(true, nil) }
}
