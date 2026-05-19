import UIKit
import APSSPSDK
import FluctSDK

public final class FluctRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {
    public var delegate: APSSPRewardVideoAdapterDelegate?
    public var rootViewController: UIViewController?
    private var mediationAd: FluctMediationRewardVideoAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let groupId = placementDic[APSSPPlacementKey.fluctGroupId.rawValue] ?? ""
        let unitId = placementDic[APSSPPlacementKey.fluctUnitId.rawValue] ?? ""
        self.mediationAd = FluctMediationRewardVideoAd(groupId: groupId, unitId: unitId)
        self.rootViewController = rootViewController
    }

    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        mediationAd?.delegate = self
        mediationAd?.load()
    }

    public func disconnectDelegate() { mediationAd?.delegate = nil; delegate = nil }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        mediationAd?.present(from: from)
        completion()
    }
}

extension FluctRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() { delegate?.rewardVideoLoadSuccess() }
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.rewardVideoLoadFail(error: error, errorMessage: errorMessage) }
    public func rewardVideoShowSuccess(message: String) { delegate?.rewardVideoShowSuccess(message: message) }
    public func rewardVideoShowFail(message: String) { delegate?.rewardVideoShowFail(message: message) }
    public func rewardVideoClosed(message: String) { delegate?.rewardVideoClosed(message: message) }
    public func rewardVideoClicked(message: String) { delegate?.rewardVideoClicked(message: message) }
    public func rewardVideoCompleted() { delegate?.rewardVideoCompleted() }
}
