//
//  APSSPNativeAd+Extension.swift
//  MediationGAM
//
//  Created by Odin on 2026/04/06.
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindGAMRenderer(renderer: APSSPGAMNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.gamNativeAdView }
        self.gamRenderer = renderer
    }
}
