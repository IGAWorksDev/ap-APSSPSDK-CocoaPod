//
//  InMobiMediationInterstitialAd.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
// import InMobiSDK


final class InMobiMediationInterstitialAd: NSObject {

    var delegate: APSSPInterstitialAdapterDelegate?

    private let placementId: String

    // private var interstitialAd: IMInterstitial?


    init(placementId: String) {
        self.placementId = placementId
    }

    func load() {
        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi Interstitial load, placementId: \(pid)")

        // interstitialAd = IMInterstitial(placementId: pid)
        // interstitialAd?.delegate = self
        // interstitialAd?.load()
    }

    func present(from: UIViewController) {
        // interstitialAd?.show(from: from)
    }
}


// MARK: - IMInterstitialDelegate
extension InMobiMediationInterstitialAd {
    // func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialLoadSuccess()
    // }
    //
    // func interstitial(_ interstitial: IMInterstitial, didFailToLoadWithError error: IMRequestStatus) {
    //     APLogger.error("InMobi Interstitial Error: \(error.localizedDescription)")
    //     delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    // }
    //
    // func interstitialWillPresent(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialShowSuccess(message: "InMobi Interstitial is show")
    // }
    //
    // func interstitial(_ interstitial: IMInterstitial, didFailToPresentWithError error: IMRequestStatus) {
    //     APLogger.error("InMobi Interstitial show fail: \(error.localizedDescription)")
    //     delegate?.interstitialShowFail(message: "InMobi Interstitial show Fail")
    // }
    //
    // func interstitialDidDismiss(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialClosed(message: "InMobi Interstitial is closed")
    // }
    //
    // func interstitialAdWasClicked(_ interstitial: IMInterstitial) {
    //     delegate?.interstitialClicked(message: "InMobi Interstitial Clicked")
    // }
}
