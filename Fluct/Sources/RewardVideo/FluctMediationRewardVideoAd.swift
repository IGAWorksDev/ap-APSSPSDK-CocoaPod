import UIKit
import APSSPSDK
import FluctSDK

final class FluctMediationRewardVideoAd: NSObject {
    var delegate: APSSPRewardVideoAdapterDelegate?
    private let groupId: String
    private let unitId: String

    init(groupId: String, unitId: String) {
        self.groupId = groupId
        self.unitId = unitId
    }

    func load() {
        guard !unitId.isEmpty else {
            APLogger.error("Fluct RewardVideo unitId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "unitId is empty")
            return
        }
        
        FSSRewardedVideo.shared.delegate = self
        FSSRewardedVideo.shared.load(withGroupId: groupId, unitId: unitId)
    }

    func present(from vc: UIViewController) {
        FSSRewardedVideo.shared.presentAd(forGroupId: groupId, unitId: unitId, from: vc)
    }
}

extension FluctMediationRewardVideoAd: FSSRewardedVideoDelegate {
    func rewardedVideoDidLoad(forGroupID groupId: String, unitId: String) {
        delegate?.rewardVideoLoadSuccess()
    }

    func rewardedVideoDidFailToLoad(forGroupId groupId: String, unitId: String, error: Error) {
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func rewardedVideoDidAppear(forGroupId groupId: String, unitId: String) {
        delegate?.rewardVideoShowSuccess(message: "Fluct RV show")
    }

    func rewardedVideoDidFailToPlay(forGroupId groupId: String, unitId: String, error: Error) {
        delegate?.rewardVideoShowFail(message: error.localizedDescription)
    }

    func rewardedVideoDidDisappear(forGroupId groupId: String, unitId: String) {
        delegate?.rewardVideoClosed(message: "Fluct RV closed")
    }

    func rewardedVideoShouldReward(forGroupID groupId: String, unitId: String) {
        delegate?.rewardVideoCompleted()
    }
}
