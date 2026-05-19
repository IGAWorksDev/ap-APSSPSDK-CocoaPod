import UIKit
import APSSPSDK
import MolocoSDK

final class MolocoMediationNativeAdView: NSObject {
    weak var delegate: APSSPNativeViewAdapterDelegate?
    private var nativeAd: (any MolocoNativeAd)?
    private let adUnitId: String
    private var biddingData: String?

    init(adUnitId: String, biddingData: String? = nil) {
        self.adUnitId = adUnitId
        self.biddingData = biddingData
    }

    @MainActor func load() {
        let params = MolocoCreateAdParams(adUnit: adUnitId, mediation: "AdPopcornSSP")
        nativeAd = Moloco.shared.createNativeAd(params: params)
        nativeAd?.delegate = self
        nativeAd?.load(bidResponse: biddingData ?? "")
    }

    func stop() {
        nativeAd?.delegate = nil
        nativeAd?.destroy()
        nativeAd = nil
    }

    func getBiddingToken() -> String {
        var token = ""
        let semaphore = DispatchSemaphore(value: 0)
        Moloco.shared.getBidToken(params: MolocoParams(mediation: "AdPopcornSSP")) { bidToken, _ in
            token = bidToken ?? ""; semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 3)
        return token
    }
}

extension MolocoMediationNativeAdView: MolocoNativeAdDelegate {
    func didLoad(ad: any MolocoAd) { delegate?.nativeLoadSuccess() }
    func failToLoad(ad: any MolocoAd, with error: Error?) { delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error?.localizedDescription) }
    func didShow(ad: any MolocoAd) { }
    func failToShow(ad: any MolocoAd, with error: Error?) { }
    func didHide(ad: any MolocoAd) { }
    func didClick(on ad: any MolocoAd) { }
    func didHandleImpression(ad: any MolocoAd) { delegate?.nativeImpression(message: "Moloco Native impression") }
    func didHandleClick(ad: any MolocoAd) { delegate?.nativeClicked(message: "Moloco Native clicked") }
}
