//
//  InMobiInitializationAdapter.swift
//  MediationInMobi
//

import Foundation
import APSSPSDK

import InMobiSDK

public final class InMobiInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { IMSdk.getVersion() }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        // TODO: 서버에서 accountId 제공 시 활성화
        // IMSdk.initWithAccountID(accountId, consentDictionary: nil)
        completion(true, nil)
    }
}
