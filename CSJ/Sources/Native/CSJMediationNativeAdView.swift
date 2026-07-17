import UIKit
import APSSPSDK
import BUAdSDK

final class CSJMediationNativeAdView: UIView, BUCustomEventProtocol {
    weak var delegate: APSSPNativeViewAdapterDelegate?
    private var nativeAdManager: BUNativeExpressAdManager?
    private var nativeAdView: BUNativeExpressAdView?
    private var csjRenderer: APSSPCSJNativeAdRenderer?
    private let placementId: String
    private weak var rootViewController: UIViewController?

    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)
        self.csjRenderer = render as? APSSPCSJNativeAdRenderer
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("CSJ Native placementId is empty")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let slot = BUAdSlot()
        slot.id = placementId
        slot.adType = .feed
        let width = UIScreen.main.bounds.width
        nativeAdManager = BUNativeExpressAdManager(slot: slot, adSize: CGSize(width: width, height: 0))
        nativeAdManager?.delegate = self
        nativeAdManager?.loadAdData(withCount: 1)
    }

    func stop() {
        nativeAdManager?.delegate = nil
        nativeAdManager = nil
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
    }
}


extension CSJMediationNativeAdView: BUNativeExpressAdViewDelegate {
    func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        guard let view = views.first else {
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "CSJ Native no ad returned")
            return
        }
        nativeAdView = view
        nativeAdView?.rootViewController = rootViewController
        nativeAdView?.render()
    }

    func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error?.localizedDescription)
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        csjRenderer?.contentView = nativeExpressAdView
        delegate?.nativeLoadSuccess()
    }

    func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error?.localizedDescription)
    }

    func nativeExpressAdViewDidClick(_ nativeExpressAdView: BUNativeExpressAdView) {
        delegate?.nativeClicked(message: "CSJ Native clicked")
    }
}
