import Foundation
import APSSPSDK
import FluctSDK

public final class FluctInitializationAdapter: APSSPInitializationProtocol {
    public init() { }
    public var sdkVersion: String? { FluctSDK.version() }
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) { completion(true, nil) }
}
