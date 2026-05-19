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
        // FAN은 별도 초기화 불필요 — 광고 요청 시 자동 초기화
        completion(true, nil)
    }
}
