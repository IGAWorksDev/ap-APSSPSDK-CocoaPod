import UIKit
import APSSPSDK
import BUAdSDK

public final class CSJInterstitialVideoAdapter: APSSPInterstitialVideoAdapterProtocol {
    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    public var rootViewController: UIViewController?
    private var mediationAd: CSJMediationFullscreenAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.csjCodeId.rawValue] ?? ""
        self.mediationAd = CSJMediationFullscreenAd(placementId: placementId, adType: .interstitialVideo)
        self.mediationAd?.delegate = self
    }

    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        mediationAd?.load()
    }

    public func disconnectDelegate() { mediationAd?.delegate = nil; delegate = nil }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        mediationAd?.show(from: from)
        completion()
    }
}

extension CSJInterstitialVideoAdapter: CSJFullscreenAdDelegate {
    func loadSuccess() { delegate?.interstitialVideoLoadSuccess() }
    func loadFail(errorMessage: String?) { delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: errorMessage) }
    func showSuccess() { delegate?.interstitialVideoShowSuccess(message: "CSJ IV show") }
    func showFail(errorMessage: String?) { delegate?.interstitialVideoShowFail(message: errorMessage ?? "CSJ IV show fail") }
    func closed() { delegate?.interstitialVideoClosed(message: "CSJ IV closed") }
    func clicked() { delegate?.interstitialVideoClicked(message: "CSJ IV clicked") }
    func completed() { }
}
