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
        guard let accountId = keys[APSSPInitKey.inMobiAccountId.key], !accountId.isEmpty else {
            completion(false, "InMobi accountId is nil or empty")
            return
        }
        
        IMSdk.initWithAccountID(accountId, consentDictionary: nil) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
}
