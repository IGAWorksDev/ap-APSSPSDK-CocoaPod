import UIKit
import APSSPSDK
import BUAdSDK

@objc
public final class APSSPCSJNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: UIView?
}

public final class CSJNativeAdapter: APSSPNativeAdapterProtocol {
    public var render: AnyObject?
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    public var rootViewController: UIViewController?
    private var nativeAdView: CSJMediationNativeAdView

    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.csjCodeId.rawValue] ?? ""
        self.nativeAdView = CSJMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, render: render)
        nativeAdView.delegate = self
    }

    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        nativeAdView.delegate = self
        nativeAdView.load()
    }

    public func disconnectDelegate() {
        nativeAdView.delegate = nil
        delegate = nil
    }

    public func stop() { nativeAdView.stop() }
}

extension CSJNativeAdapter: APSSPNativeViewAdapterDelegate {
    public func nativeLoadSuccess() { delegate?.nativeLoadSuccess() }
    public func nativeLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.nativeLoadFail(error: error, errorMessage: errorMessage) }
    public func nativeClicked(message: String) { delegate?.nativeClicked(message: message) }
    public func nativeImpression(message: String) { delegate?.nativeImpression(message: message) }
}
