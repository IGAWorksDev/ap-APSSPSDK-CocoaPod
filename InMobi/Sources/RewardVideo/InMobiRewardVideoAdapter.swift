//
//  InMobiRewardVideoAdapter.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK


final public class InMobiRewardVideoAdapter: APSSPRewardVideoAdapterProtocol {

    public var rootViewController: UIViewController?

    public var delegate: APSSPRewardVideoAdapterDelegate?

    private var rewardVideoAd: InMobiMediationRewardVideoAd


    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.inMobiPlacementId.rawValue] ?? ""
        rewardVideoAd = InMobiMediationRewardVideoAd(placementId: placementId, rootViewController: rootViewController)
        rewardVideoAd.delegate = self
    }

    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        rewardVideoAd.load()
    }

    public func disconnectDelegate() {
        rewardVideoAd.delegate = nil
        delegate = nil
    }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        rewardVideoAd.present(from: from) { completion() }
    }
}


extension InMobiRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() {
        delegate?.rewardVideoLoadSuccess()
    }

    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.rewardVideoLoadFail(error: error, errorMessage: errorMessage)
    }

    public func rewardVideoShowSuccess(message: String) {
        delegate?.rewardVideoShowSuccess(message: message)
    }

    public func rewardVideoShowFail(message: String) {
        delegate?.rewardVideoShowFail(message: message)
    }

    public func rewardVideoClicked(message: String) {
        delegate?.rewardVideoClicked(message: message)
    }

    public func rewardVideoClosed(message: String) {
        delegate?.rewardVideoClosed(message: message)
    }

    public func rewardVideoCompleted() {
        delegate?.rewardVideoCompleted()
    }
}
