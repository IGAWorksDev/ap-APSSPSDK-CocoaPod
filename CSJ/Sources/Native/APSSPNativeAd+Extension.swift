//
//  APSSPNativeAd+Extension.swift
//  MediationCSJ
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindCSJRenderer(renderer: APSSPCSJNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.nativeAdView }
        self.csjRenderer = renderer
    }
}
