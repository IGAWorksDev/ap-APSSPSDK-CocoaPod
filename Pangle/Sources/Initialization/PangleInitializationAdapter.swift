//
//  PangleInitializationAdapter.swift
//  MediationPangle
//

import Foundation
import APSSPSDK
import PAGAdSDK

public final class PangleInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { PAGSdk.sdkVersion }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appId = keys[APSSPInitKey.pangleAppId.key] else {
            completion(false, "appKey is nil")
            return
        }
        let config = PAGConfig.share()
        config.appID = appId
        PAGSdk.start(with: config) { success, error in
            completion(success, error?.localizedDescription)
        }
    }
}
