//
//  CaulyInitializationAdapter.swift
//  MediationCauly
//
//  Created by Odin.송황호 on 6/24/24.
//

import Foundation
import APSSPSDK
import CaulySDK

public final class CaulyInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? { CAULY_SDK_VERSION }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appCode = keys[APSSPInitKey.caulyAppCode.key] else {
            completion(false, "appKey is nil")
            return
        }
        let caulySetting = CaulyAdSetting.global()
        caulySetting?.appCode = appCode
        completion(true, nil)
    }
}
