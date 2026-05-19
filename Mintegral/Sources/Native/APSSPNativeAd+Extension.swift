//
//  APSSPNativeAd+Extension.swift
//  MediationMintegral
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindMintegralRenderer(renderer: APSSPMintegralNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.nativeAdView }
        self.mintegralRenderer = renderer
    }
}
