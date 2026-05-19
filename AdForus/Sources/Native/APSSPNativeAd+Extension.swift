//
//  APSSPNativeAd+Extension.swift
//  MediationAdForus
//
//  Created by Kiro on 2026/04/06.
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindAdForusRenderer(renderer: APSSPAdForusNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.adforusNativeAdView }
        self.adforusRenderer = renderer
    }
}
