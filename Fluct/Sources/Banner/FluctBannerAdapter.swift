import UIKit
import APSSPSDK
import FluctSDK

public final class FluctBannerAdapter: APSSPBannerAdapterProtocol {
    private let bannerView: FluctMediationBannerView
    weak public var delegate: APSSPBannerAdapterDelegate?
    weak public var rootViewController: UIViewController?

    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any?]) {
        let groupId = placementDic[APSSPPlacementKey.fluctGroupId.rawValue] ?? ""
        let unitId = placementDic[APSSPPlacementKey.fluctUnitId.rawValue] ?? ""
        self.bannerView = FluctMediationBannerView(groupId: groupId, unitId: unitId, bannerType: bannerType)
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }

    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        bannerView.load()
    }

    public func disconnectDelegate() { bannerView.delegate = nil; delegate = nil }
    public func stop() { bannerView.stop() }
}

extension FluctBannerAdapter: APSSPBannerAdapterDelegate {
    public func bannerViewSuccess(bannerView: UIView) { delegate?.bannerViewSuccess(bannerView: bannerView) }
    public func bannerViewFailed(bannerView: UIView, error: APSSPNetworkError, errorMessage: String?) { delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: errorMessage) }
    public func bannerViewClicked(message: String) { delegate?.bannerViewClicked(message: message) }
    public func bannerViewImpression(message: String) { delegate?.bannerViewImpression(message: message) }
}
