import UIKit
import APSSPSDK
import BUAdSDK

final class CSJMediationRewardVideoAd: NSObject {
    weak var delegate: CSJFullscreenAdDelegate?
    private var rewardedAd: BUNativeExpressRewardedVideoAd?
    private let placementId: String

    init(placementId: String) {
        self.placementId = placementId
    }

    func load() {
        let model = BURewardedVideoModel()
        model.userId = ""
        rewardedAd = BUNativeExpressRewardedVideoAd(slotID: placementId, rewardedVideoModel: model)
        rewardedAd?.delegate = self
        rewardedAd?.loadData()
    }

    func show(from vc: UIViewController) {
        rewardedAd?.show(fromRootViewController: vc)
    }
}

extension CSJMediationRewardVideoAd: BUNativeExpressRewardedVideoAdDelegate {
    func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.loadSuccess()
    }

    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        delegate?.loadFail(errorMessage: error?.localizedDescription)
    }

    func nativeExpressRewardedVideoAdDidVisible(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.showSuccess()
    }

    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.closed()
    }

    func nativeExpressRewardedVideoAdDidClick(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.clicked()
    }

    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        delegate?.completed()
    }
}
