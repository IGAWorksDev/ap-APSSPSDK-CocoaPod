import UIKit
import APSSPSDK
import FluctSDK

public final class FluctInterstitialAdapter: APSSPInterstitialAdapterProtocol {
    public var rootViewController: UIViewController?
    public var delegate: APSSPInterstitialAdapterDelegate?
    private var mediationAd: FluctMediationInterstitialAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let groupId = placementDic[APSSPPlacementKey.fluctGroupId.rawValue] ?? ""
        let unitId = placementDic[APSSPPlacementKey.fluctUnitId.rawValue] ?? ""
        self.mediationAd = FluctMediationInterstitialAd(groupId: groupId, unitId: unitId)
        self.rootViewController = rootViewController
    }

    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        mediationAd?.delegate = self
        mediationAd?.load()
    }

    public func disconnectDelegate() { mediationAd?.delegate = nil; delegate = nil }

    public func present(from: UIViewController, completion: () -> Void) {
        mediationAd?.present(from: from)
        completion()
    }
}

extension FluctInterstitialAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() { delegate?.interstitialLoadSuccess() }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.interstitialLoadFail(error: error, errorMessage: errorMessage) }
    public func interstitialShowSuccess(message: String) { delegate?.interstitialShowSuccess(message: message) }
    public func interstitialShowFail(message: String) { delegate?.interstitialShowFail(message: message) }
    public func interstitialClosed(message: String) { delegate?.interstitialClosed(message: message) }
    public func interstitialClicked(message: String) { delegate?.interstitialClicked(message: message) }
}
