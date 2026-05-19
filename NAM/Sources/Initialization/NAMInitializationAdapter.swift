//
//  NAMInitializationAdapter.swift
//  MediationNAM
//
//  Created by Odin.송황호 on 5/23/24.
//

import Foundation
import APSSPSDK
import GFPSDK

public final class NAMInitializationAdapter: NSObject, APSSPInitializationProtocol {
    
    public override init() { }
    
    public var sdkVersion: String? { GFPAdManager.sdkVersion() }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let publisherCd = keys[APSSPInitKey.namPublisherCode.key] else {
            completion(false, "appKey is nil")
            return
        }
        Task { @MainActor in
            await GFPAdManager.setup(withPublisherCd: publisherCd, target: self)
            completion(true, nil)
        }
    }
}

extension NAMInitializationAdapter: GFPAdManagerDelegate {
    public func attStatus() -> GFPATTAuthorizationStatus {
        return .authorized
    }
}
