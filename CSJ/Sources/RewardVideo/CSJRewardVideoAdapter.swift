import UIKit
import APSSPSDK
import BUAdSDK

public final class CSJRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {
    public var delegate: APSSPRewardVideoAdapterDelegate?
    public var rootViewController: UIViewController?
    private var mediationAd: CSJMediationRewardVideoAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.csjCodeId.rawValue] ?? ""
        self.mediationAd = CSJMediationRewardVideoAd(placementId: placementId)
        self.mediationAd?.delegate = self
    }

    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        mediationAd?.load()
    }

    public func disconnectDelegate() { mediationAd?.delegate = nil; delegate = nil }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        mediationAd?.show(from: from)
        completion()
    }
}

extension CSJRewardVideoAdapter: CSJFullscreenAdDelegate {
    func loadSuccess() { delegate?.rewardVideoLoadSuccess() }
    func loadFail(errorMessage: String?) { delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: errorMessage) }
    func showSuccess() { delegate?.rewardVideoShowSuccess(message: "CSJ RV show") }
    func showFail(errorMessage: String?) { delegate?.rewardVideoShowFail(message: errorMessage ?? "CSJ RV show fail") }
    func closed() { delegate?.rewardVideoClosed(message: "CSJ RV closed") }
    func clicked() { delegate?.rewardVideoClicked(message: "CSJ RV clicked") }
    func completed() { delegate?.rewardVideoCompleted() }
}
