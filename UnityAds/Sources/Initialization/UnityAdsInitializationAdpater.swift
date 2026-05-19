//
//  UnityAdsInitialization.swift
//  MediationUnityAds
//
//  Created by Odin.송황호 on 6/25/24.
//

import UIKit
import APSSPSDK
import UnityAds

final class UnityAdsInitializationAdpater: NSObject, APSSPInitializationProtocol {
   
    public override init() { }
    
    public var sdkVersion: String? { UnityAds.getVersion() }
    
    private var completion: ((Bool, String?) -> Void)?
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let gameId = keys[APSSPInitKey.unityGameId.key] else {
            completion(false, "appKey is nil")
            return
        }
        if UnityAds.isInitialized() {
            completion(true, nil)
            return
        }
        self.completion = completion
        UnityAds.initialize(gameId, testMode: false, initializationDelegate: self)
    }
}

// MARK: - UnityAds
extension UnityAdsInitializationAdpater: UnityAdsInitializationDelegate {
    func initializationComplete() {
        completion?(true, nil)
        completion = nil
    }

    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        completion?(false, message)
        completion = nil
    }
}
