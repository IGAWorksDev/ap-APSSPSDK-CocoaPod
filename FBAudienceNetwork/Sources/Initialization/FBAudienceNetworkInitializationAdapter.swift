//
//  FBAudienceNetworkInitializationAdapter.swift
//  MediationFBAudienceNetwork
//

import Foundation
import APSSPSDK
import FBAudienceNetwork

public final class FBAudienceNetworkInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { FB_AD_SDK_VERSION }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        FBAudienceNetworkAds.initialize(with: nil) { result in
            completion(result.isSuccess, result.message)
        }
    }
}
