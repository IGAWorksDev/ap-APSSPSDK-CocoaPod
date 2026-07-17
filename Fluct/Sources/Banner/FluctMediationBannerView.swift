import UIKit
import APSSPSDK
import FluctSDK

final class FluctMediationBannerView: UIView {
    weak var delegate: APSSPBannerAdapterDelegate?
    private var adView: FSSAdView?
    private let groupId: String
    private let unitId: String
    private let bannerType: APSSPBannerSize

    init(groupId: String, unitId: String, bannerType: APSSPBannerSize) {
        self.groupId = groupId
        self.unitId = unitId
        self.bannerType = bannerType
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func load() {
        guard !unitId.isEmpty else {
            APLogger.error("Fluct Banner unitId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "unitId is empty")
            return
        }
        
        let adSize: FSSAdSize
        switch bannerType {
        case .banner300x250: adSize = FSSAdSize300x250
        case .banner320x100: adSize = FSSAdSize320x100
        default: adSize = FSSAdSize320x50
        }
        adView = FSSAdView(groupId: groupId, unitId: unitId, adSize: adSize)
        adView?.delegate = self
        if let adView {
            addSubview(adView)
            frame = CGRect(origin: .zero, size: CGSize(width: adView.adSize.size.width, height: adView.adSize.size.height))
        }
        adView?.loadAd()
    }

    func stop() {
        adView?.delegate = nil
        adView?.removeFromSuperview()
        adView = nil
    }
}

extension FluctMediationBannerView: FSSAdViewDelegate {
    func adViewDidStoreAd(_ adView: FSSAdView) {
        delegate?.bannerViewSuccess(bannerView: self)
    }

    func adView(_ adView: FSSAdView, didFailToStoreAdWithError error: Error) {
        delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func willLeaveApplicationForAdView(_ adView: FSSAdView) {
        delegate?.bannerViewClicked(message: "Fluct Banner clicked")
    }
}
