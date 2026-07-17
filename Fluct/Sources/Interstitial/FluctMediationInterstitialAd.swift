import UIKit
import APSSPSDK
import FluctSDK

final class FluctMediationInterstitialAd: NSObject {
    var delegate: APSSPInterstitialAdapterDelegate?
    private var interstitialAd: FSSVideoInterstitial?
    private let groupId: String
    private let unitId: String

    init(groupId: String, unitId: String) {
        self.groupId = groupId
        self.unitId = unitId
    }

    func load() {
        guard !unitId.isEmpty else {
            APLogger.error("Fluct Interstitial unitId is empty")
            delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "unitId is empty")
            return
        }
        
        let setting = FSSVideoInterstitialSetting()
        interstitialAd = FSSVideoInterstitial(groupId: groupId, unitId: unitId, setting: setting)
        interstitialAd?.delegate = self
        interstitialAd?.loadAd()
    }

    func present(from vc: UIViewController) {
        interstitialAd?.presentAd(from: vc)
    }
}

extension FluctMediationInterstitialAd: FSSVideoInterstitialDelegate {
    func videoInterstitialDidLoad(_ interstitial: FSSVideoInterstitial) {
        delegate?.interstitialLoadSuccess()
    }

    func videoInterstitial(_ interstitial: FSSVideoInterstitial, didFailToLoadWithError error: Error) {
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func videoInterstitialDidAppear(_ interstitial: FSSVideoInterstitial) {
        delegate?.interstitialShowSuccess(message: "Fluct IS show")
    }

    func videoInterstitial(_ interstitial: FSSVideoInterstitial, didFailToPlayWithError error: Error) {
        delegate?.interstitialShowFail(message: error.localizedDescription)
    }

    func videoInterstitialDidDisappear(_ interstitial: FSSVideoInterstitial) {
        delegate?.interstitialClosed(message: "Fluct IS closed")
    }
}
