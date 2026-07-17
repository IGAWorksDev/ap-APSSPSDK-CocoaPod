import UIKit
import APSSPSDK
import BUAdSDK

final class CSJMediationBannerView: UIView {
    weak var delegate: APSSPBannerAdapterDelegate?
    private var bannerAd: BUNativeExpressBannerView?
    private let placementId: String
    private let bannerType: APSSPBannerSize
    private weak var rootViewController: UIViewController?

    init(placementId: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("CSJ Banner placementId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let adSize: CGSize = (bannerType == .banner300x250) ? CGSize(width: 300, height: 250) : CGSize(width: 320, height: 50)
        guard let rootViewController else {
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "rootViewController is nil")
            return }
        bannerAd = BUNativeExpressBannerView(slotID: placementId, rootViewController: rootViewController, adSize: adSize)
        bannerAd?.delegate = self
        bannerAd?.loadAdData()
    }

    func stop() {
        bannerAd?.delegate = nil
        bannerAd?.removeFromSuperview()
        bannerAd = nil
    }
}

extension CSJMediationBannerView: BUNativeExpressBannerViewDelegate {
    func nativeExpressBannerAdViewRenderSuccess(_ bannerAdView: BUNativeExpressBannerView) {
        delegate?.bannerViewSuccess(bannerView: bannerAdView)
    }

    func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error?.localizedDescription)
    }

    func nativeExpressBannerAdViewRenderFail(_ bannerAdView: BUNativeExpressBannerView, error: Error?) {
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error?.localizedDescription)
    }

    func nativeExpressBannerAdViewDidClick(_ bannerAdView: BUNativeExpressBannerView) {
        delegate?.bannerViewClicked(message: "CSJ Banner clicked")
    }
}
