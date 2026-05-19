//
//  VungleInitializationAdapter.swift
//  MediationVungle
//

import Foundation
import APSSPSDK
import VungleAdsSDK

public final class VungleInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { VungleAds.sdkVersion }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appId = keys[APSSPInitKey.vungleAppId.key] else {
            completion(false, "appKey is nil")
            return
        }
        VungleAds.initWithAppId(appId) { error in
            completion(error == nil, error?.localizedDescription)
        }
    }
}
