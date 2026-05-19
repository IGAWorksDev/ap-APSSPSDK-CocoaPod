//
//  AppLovinMaxInitializationAdapter.swift
//  MediationAppLovinMax
//

import Foundation
import APSSPSDK
import AppLovinSDK

public final class AppLovinMaxInitializationAdapter: APSSPInitializationProtocol {
    
    private static var isInitialized = false
    
    public init() { }
    
    public var sdkVersion: String? { ALSdk.version() }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard !Self.isInitialized else {
            completion(true, nil)
            return
        }
        Self.isInitialized = true
        
        // sdkKey: 서버 키 > Info.plist AppLovinSdkKey
        guard let sdkKey = keys[APSSPInitKey.appLovinKey.key]else {
            completion(false, "appID or apiKey is nil")
            return
        }
        
        let initConfig = ALSdkInitializationConfiguration(sdkKey: sdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        ALSdk.shared().initialize(with: initConfig) { _ in
            completion(true, nil)
        }
    }
}
