//
//  InMobiMediationInterstitialVideoAd.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
// import InMobiSDK


final class InMobiMediationInterstitialVideoAd: NSObject {

    var delegate: APSSPInterstitialVideoAdapterDelegate?

    private let placementId: String

    // private var interstitialVideoAd: IMInterstitial?


    init(placementId: String) {
        self.placementId = placementId
    }

    func load() {
        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi InterstitialVideo load, placementId: \(pid)")

        // interstitialVideoAd = IMInterstitial(placementId: pid)
        // interstitialVideoAd?.delegate = self
        // interstitialVideoAd?.load()
    }

    func present(from: UIViewController, completion: @escaping () -> Void) {
        // interstitialVideoAd?.show(from: from)
        completion()
    }
}


// MARK: - IMInterstitialDelegate
extension InMobiMediationInterstitialVideoAd {
    // func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialVideoLoadSuccess()
    // }
    //
    // func interstitial(_ interstitial: IMInterstitial, didFailToLoadWithError error: IMRequestStatus) {
    //     APLogger.error("InMobi InterstitialVideo Error: \(error.localizedDescription)")
    //     delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    // }
    //
    // func interstitialWillPresent(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialVideoShowSuccess(message: "InMobi InterstitialVideo is show")
    // }
    //
    // func interstitial(_ interstitial: IMInterstitial, didFailToPresentWithError error: IMRequestStatus) {
    //     delegate?.interstitialVideoShowFail(message: "InMobi InterstitialVideo show Fail: \(error.localizedDescription)")
    // }
    //
    // func interstitialDidDismiss(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialVideoClosed(message: "InMobi InterstitialVideo is closed")
    // }
    //
    // func interstitialAdWasClicked(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialVideoClicked(message: "InMobi InterstitialVideo Clicked")
    // }
}
