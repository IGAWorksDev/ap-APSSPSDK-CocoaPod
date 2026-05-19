import UIKit
import APSSPSDK
import BUAdSDK

protocol CSJFullscreenAdDelegate: AnyObject {
    func loadSuccess()
    func loadFail(errorMessage: String?)
    func showSuccess()
    func showFail(errorMessage: String?)
    func closed()
    func clicked()
    func completed()
}

enum CSJFullscreenAdType { case interstitial, interstitialVideo }

final class CSJMediationFullscreenAd: NSObject {
    weak var delegate: CSJFullscreenAdDelegate?
    private var fullscreenAd: BUNativeExpressFullscreenVideoAd?
    private let placementId: String
    private let adType: CSJFullscreenAdType

    init(placementId: String, adType: CSJFullscreenAdType) {
        self.placementId = placementId
        self.adType = adType
    }

    func load() {
        fullscreenAd = BUNativeExpressFullscreenVideoAd(slotID: placementId)
        fullscreenAd?.delegate = self
        fullscreenAd?.loadData()
    }

    func show(from vc: UIViewController) {
        fullscreenAd?.show(fromRootViewController: vc)
    }
}

extension CSJMediationFullscreenAd: BUNativeExpressFullscreenVideoAdDelegate {
    func nativeExpressFullscreenVideoAdDidDownLoadVideo(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        delegate?.loadSuccess()
    }

    func nativeExpressFullscreenVideoAd(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {
        delegate?.loadFail(errorMessage: error?.localizedDescription)
    }

    func nativeExpressFullscreenVideoAdDidVisible(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        delegate?.showSuccess()
    }

    func nativeExpressFullscreenVideoAdDidClose(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        delegate?.closed()
    }

    func nativeExpressFullscreenVideoAdDidClick(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        delegate?.clicked()
    }
}
