//
//  APSSPNativeAd+Extension.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindInMobiRenderer(renderer: APSSPInMobiNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.inMobiNativeAdView }
        self.inMobiRenderer = renderer
    }
}
