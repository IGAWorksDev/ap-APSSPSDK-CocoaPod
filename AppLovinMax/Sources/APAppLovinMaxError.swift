//
//  APAppLovinMaxError.swift
//  MediationAppLovin
//
//  Created by Odin.송황호 on 7/3/24.
//

import Foundation


enum APAppLovinMaxError: Int32 {
    case mediationerror = -1
    case noad = 204
    case timeout = -1001
    case network = -1009
    case error = -5001
    case applovinMaxError = -5201
    
    var description: String {
        switch self {
        case .mediationerror: return "errorCode = -1, Indicates an unspecified error with one of the mediated network SDKs."
        case .noad: return "errorCode = 204, Indicates that no ads are currently eligible for your device."
        case .timeout: return "errorCode = -1001, Indicates that the ad request timed out (usually due to poor connectivity)."
        case .network: return "errorCode = -1009, Indicates that the device is not connected to the internet (e.g. airplane mode)."
        case .error: return "errorCode = -5001, Indicates that the ad failed to load due to various reasons (such as no networks being able to fill)."
        case .applovinMaxError: return "errorCode = -5201, Indicates an internal state error with the AppLovin MAX SDK."
        }
    }
}

