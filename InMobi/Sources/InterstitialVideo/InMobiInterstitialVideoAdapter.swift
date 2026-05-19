//
//  InMobiInterstitialVideoAdapter.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK


final public class InMobiInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {

    public var rootViewController: UIViewController?

    public var delegate: APSSPInterstitialVideoAdapterDelegate?

    private var interstitialVideoAd: InMobiMediationInterstitialVideoAd


    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.inMobiPlacementId.rawValue] ?? ""
        interstitialVideoAd = InMobiMediationInterstitialVideoAd(placementId: placementId)
        interstitialVideoAd.delegate = self
    }

    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        interstitialVideoAd.load()
    }

    public func disconnectDelegate() {
        interstitialVideoAd.delegate = nil
        delegate = nil
    }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        interstitialVideoAd.present(from: from) { completion() }
    }
}


extension InMobiInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadSuccess() {
        delegate?.interstitialVideoLoadSuccess()
    }

    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage)
    }

    public func interstitialVideoShowSuccess(message: String) {
        delegate?.interstitialVideoShowSuccess(message: message)
    }

    public func interstitialVideoShowFail(message: String) {
        delegate?.interstitialVideoShowFail(message: message)
    }

    public func interstitialVideoClicked(message: String) {
        delegate?.interstitialVideoClicked(message: message)
    }

    public func interstitialVideoClosed(message: String) {
        delegate?.interstitialVideoClosed(message: message)
    }
}
