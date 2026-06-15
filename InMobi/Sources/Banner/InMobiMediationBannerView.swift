//
//  InMobiMediationBannerView.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
import InMobiSDK


final class InMobiMediationBannerView: UIView {

    weak var delegate: APSSPBannerAdapterDelegate?

    private let placementId: String

    private var bannerAd: IMBanner?

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
        guard !placementId.isEmpty else {
            APLogger.error("InMobi Banner placementId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard bannerType == .banner320x50 else {
            APLogger.error("InMobi Banner only supports 320x50")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "InMobi Banner only supports 320x50")
            return
        }

        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi Banner load, placementId: \(pid)")

        let banner = IMBanner(frame: CGRect(x: 0, y: 0, width: 320, height: 50), placementId: pid)
        banner.delegate = self
        bannerAd = banner
        addSubview(banner)
        banner.load()
    }

    func stop() {
        if !subviews.isEmpty {
            subviews.first?.removeFromSuperview()
        }
        bannerAd?.delegate = nil
        bannerAd = nil
    }
}


// MARK: - IMBannerDelegate
extension InMobiMediationBannerView: IMBannerDelegate {
    func banner(_ banner: IMBanner, didReceiveWithMetaInfo info: IMAdMetaInfo) {
        delegate?.bannerViewSuccess(bannerView: self)
    }

    func banner(_ banner: IMBanner, didFailToLoadWithError error: IMRequestStatus) {
        APLogger.error("InMobi Banner Error: \(error.localizedDescription)")
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func banner(_ banner: IMBanner, didInteractWithParams params: [String: Any]?) {
        delegate?.bannerViewClicked(message: "InMobi Banner Clicked")
    }

    func bannerDidFinishLoading(_ banner: IMBanner) {
        delegate?.bannerViewImpression(message: "InMobi Banner Impression")
    }
}
