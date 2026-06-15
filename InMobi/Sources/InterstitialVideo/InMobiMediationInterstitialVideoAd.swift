//
//  InMobiMediationInterstitialVideoAd.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
import InMobiSDK


final class InMobiMediationInterstitialVideoAd: NSObject {

    var delegate: APSSPInterstitialVideoAdapterDelegate?

    private let placementId: String

    private var interstitialVideoAd: IMInterstitial?


    init(placementId: String) {
        self.placementId = placementId
    }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("InMobi InterstitialVideo placementId is empty")
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi InterstitialVideo load, placementId: \(pid)")

        interstitialVideoAd = IMInterstitial(placementId: pid)
        interstitialVideoAd?.delegate = self
        interstitialVideoAd?.load()
    }

    func present(from: UIViewController, completion: @escaping () -> Void) {
        interstitialVideoAd?.show(from: from)
        completion()
    }
}


// MARK: - IMInterstitialDelegate
extension InMobiMediationInterstitialVideoAd: IMInterstitialDelegate {
    func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
        delegate?.interstitialVideoLoadSuccess()
    }

    func interstitial(_ interstitial: IMInterstitial, didFailToLoadWithError error: IMRequestStatus) {
        APLogger.error("InMobi InterstitialVideo Error: \(error.localizedDescription)")
        delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func interstitialWillPresent(_ interstitial: IMInterstitial) {
        delegate?.interstitialVideoShowSuccess(message: "InMobi InterstitialVideo show")
    }

    func interstitial(_ interstitial: IMInterstitial, didFailToPresentWithError error: IMRequestStatus) {
        delegate?.interstitialVideoShowFail(message: "InMobi InterstitialVideo show Fail")
    }

    func interstitialDidDismiss(_ interstitial: IMInterstitial) {
        delegate?.interstitialVideoClosed(message: "InMobi InterstitialVideo closed")
    }

    func interstitial(_ interstitial: IMInterstitial, didInteractWithParams params: [String: Any]?) {
        delegate?.interstitialVideoClicked(message: "InMobi InterstitialVideo Clicked")
    }
}
