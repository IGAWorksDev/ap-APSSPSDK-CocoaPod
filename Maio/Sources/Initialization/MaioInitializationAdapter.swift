import Foundation
import APSSPSDK
import Maio

public final class MaioInitializationAdapter: APSSPInitializationProtocol {
    public init() { }
    public var sdkVersion: String? { MaioVersion.shared.toString() }
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) { completion(true, nil) }
}
