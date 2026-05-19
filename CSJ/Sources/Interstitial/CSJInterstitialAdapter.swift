import UIKit
import APSSPSDK
import BUAdSDK

public final class CSJInterstitialAdapter: APSSPInterstitialAdapterProtocol {
    public var rootViewController: UIViewController?
    public var delegate: APSSPInterstitialAdapterDelegate?
    private var mediationAd: CSJMediationFullscreenAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.csjCodeId.rawValue] ?? ""
        self.mediationAd = CSJMediationFullscreenAd(placementId: placementId, adType: .interstitial)
        self.mediationAd?.delegate = self
    }

    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        mediationAd?.load()
    }

    public func disconnectDelegate() { mediationAd?.delegate = nil; delegate = nil }

    public func present(from: UIViewController, completion: () -> Void) {
        mediationAd?.show(from: from)
        completion()
    }
}

extension CSJInterstitialAdapter: CSJFullscreenAdDelegate {
    func loadSuccess() { delegate?.interstitialLoadSuccess() }
    func loadFail(errorMessage: String?) { delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: errorMessage) }
    func showSuccess() { delegate?.interstitialShowSuccess(message: "CSJ IS show") }
    func showFail(errorMessage: String?) { delegate?.interstitialShowFail(message: errorMessage ?? "CSJ IS show fail") }
    func closed() { delegate?.interstitialClosed(message: "CSJ IS closed") }
    func clicked() { delegate?.interstitialClicked(message: "CSJ IS clicked") }
    func completed() { }
}
