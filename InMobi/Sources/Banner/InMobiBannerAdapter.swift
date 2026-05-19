//
//  InMobiBannerAdapter.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK


final public class InMobiBannerAdapter: APSSPBannerAdapterProtocol {

    private let bannerView: InMobiMediationBannerView

    weak public var delegate: APSSPBannerAdapterDelegate?

    weak public var rootViewController: UIViewController?

    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.inMobiPlacementId.rawValue] ?? ""
        self.bannerView = InMobiMediationBannerView(placementId: placementId,
                                                     bannerType: bannerType,
                                                     rootViewController: rootViewController)
        self.rootViewController = rootViewController
        bannerView.delegate = self
    }

    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        bannerView.load()
    }

    public func disconnectDelegate() {
        bannerView.delegate = nil
        delegate = nil
    }

    public func stop() {
        bannerView.stop()
    }
}


extension InMobiBannerAdapter: APSSPBannerAdapterDelegate {
    public func bannerViewSuccess(bannerView: UIView) {
        delegate?.bannerViewSuccess(bannerView: bannerView)
    }

    public func bannerViewFailed(bannerView: UIView, error: APSSPNetworkError, errorMessage: String?) {
        delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: errorMessage)
    }

    public func bannerViewClicked(message: String) {
        delegate?.bannerViewClicked(message: message)
    }

    public func bannerViewImpression(message: String) {
        delegate?.bannerViewImpression(message: message)
    }
}
