//
//  AdFitInitializationAdapter.swift
//  AdFitInitializationAdapter
//
//  Created by Odin.송황호 on 2/16/24.
//

import Foundation
import APSSPSDK
import AdFitSDK

public final class AdFitInitializationAdapter: APSSPInitializationProtocol {
    public init() { }
    public var sdkVersion: String? {
        Bundle(for: AdFitBannerAdView.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) { completion(true, nil) }
}
