//
//  APSSPNativeAd+Extension.swift
//  MediationADOP
//
//  Created by Odin.송황호 on 5/20/24.
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindADOPRenderer(renderer: APSSPADOPNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.admobNativewAdView }
        self.adopRenderer = renderer
    }
}
