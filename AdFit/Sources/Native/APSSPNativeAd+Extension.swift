//
//  APSSPNativeAd+Extension.swift
//  MediationAdFit
//
//  Created by Odin.송황호 on 5/28/24.
//

import UIKit

import APSSPSDK
import AdFitSDK

extension APSSPNativeAd {
    @objc public func bindAdFitRenderer(renderer: APSSPAdFitNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.adfitNativewAdView }
        self.adfitRenderer = renderer
    }
}
