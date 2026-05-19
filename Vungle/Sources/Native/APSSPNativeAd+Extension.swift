//
//  APSSPNativeAd+Extension.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindVungleRenderer(renderer: APSSPVungleNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.nativeAdView }
        self.vungleRenderer = renderer
    }
}
