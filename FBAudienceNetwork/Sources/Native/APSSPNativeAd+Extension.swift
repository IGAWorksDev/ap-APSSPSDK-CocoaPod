//
//  APSSPNativeAd+Extension.swift
//  MediationAdMob
//
//  Created by Odin.송황호 on 5/20/24.
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindFBANRenderer(renderer: APSSPFBANNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.adUIView }
        self.FBANNativeRenderer = renderer
    }
    
    @objc public func bindFBANNativeBannerRenderer(renderer: APSSPFBANNativeBannerRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.adUIView }
        self.FBANnativeBannerRenderer = renderer
    }
}
