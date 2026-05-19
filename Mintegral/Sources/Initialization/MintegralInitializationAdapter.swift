//
//  MintegralInitializationAdapter.swift
//  MediationMintegral
//

import Foundation
import APSSPSDK
import MTGSDK

public final class MintegralInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { MTGSDK.sdkVersion() }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appID = keys[APSSPInitKey.mintegralAppId.key],
              let apiKey = keys[APSSPInitKey.mintegralAppkey.key] else {
            completion(false, "appID or apiKey is nil")
            return
        }
        MTGSDK.sharedInstance().setAppID(appID, apiKey: apiKey)
        completion(true, nil)
    }
}
