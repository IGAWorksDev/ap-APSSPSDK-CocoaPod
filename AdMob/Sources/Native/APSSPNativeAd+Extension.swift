//
//  APSSPNativeAd+Extension.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 5/20/24.
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindAdMobRenderer(renderer: APSSPAdMobNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.admobNativewAdView }
        self.adMobRenderer = renderer
    }
}
