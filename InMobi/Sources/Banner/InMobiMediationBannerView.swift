//
//  InMobiMediationBannerView.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
// import InMobiSDK


final class InMobiMediationBannerView: UIView {

    weak var delegate: APSSPBannerAdapterDelegate?

    private let placementId: String

    // private var bannerAd: IMBanner?

    private var rootViewController: UIViewController?

    private var bannerType: APSSPBannerSize


    init(placementId: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        super.init(frame: CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load() {
        // InMobi Banner는 320x50만 지원
        guard bannerType == .banner320x50 else {
            APLogger.error("InMobi Banner only supports 320x50")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "InMobi Banner only supports 320x50")
            return
        }

        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi Banner load, placementId: \(pid)")

        // let banner = IMBanner(frame: CGRect(x: 0, y: 0, width: 320, height: 50), placementId: pid)
        // banner.delegate = self
        // bannerAd = banner
        // addSubview(banner)
        // banner.load()
    }

    func stop() {
        if !subviews.isEmpty {
            subviews.first?.removeFromSuperview()
        }
        // bannerAd?.delegate = nil
        // bannerAd = nil
    }
}


// MARK: - IMBannerDelegate
extension InMobiMediationBannerView {
    // func banner(_ banner: IMBanner, didReceiveWithMetaInfo info: IMAdMetaInfo) {
    //     delegate?.bannerViewSuccess(bannerView: self)
    // }
    //
    // func bannerAd(_ bannerAd: IMBanner, didFailToLoadWithError error: IMRequestStatus) {
    //     APLogger.error("InMobi Banner Error: \(error.localizedDescription)")
    //     delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: nil)
    // }
    //
    // func bannerAdWasClicked(_ bannerAd: IMBanner) {
    //     delegate?.bannerViewClicked(message: "InMobi Banner Clicked")
    // }
}
