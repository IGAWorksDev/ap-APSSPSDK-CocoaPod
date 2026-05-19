//
//  CaulyMediationInterstitialAd.swift
//  MediationCauly
//
//  Created by Odin.송황호 on 5/29/24.
//

import UIKit

import APSSPSDK
import CaulySDK


final class CaulyMediationInterstitialAd: NSObject {
    
    var delegate: APSSPInterstitialAdapterDelegate?
    
    private let placementId: String
    
    private var interstitialAd: CaulyInterstitialAd?
    
    private var parentViewController: UIViewController?
    
    init(placementId: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.parentViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: () -> Void) {
        if interstitialAd != nil {
            interstitialAd?.show()
            completion()
        } else {
            delegate?.interstitialShowFail(message: "Cauly Intersititial ShowFail")
        }
    }
    
    func load() {
        guard let parentViewController else {
            APLogger.error("Cauly must set rootViewController")
            delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }

        interstitialAd = CaulyInterstitialAd.init(parentViewController: parentViewController)
        interstitialAd?.delegate = self                //  전면 delegate 설정
        interstitialAd?.startRequest()                 //  전면광고 요청
    }
}


extension CaulyMediationInterstitialAd: CaulyInterstitialAdDelegate {
    
    func didReceive(_ interstitialAd: CaulyInterstitialAd!, isChargeableAd: Bool) {
        
    }
    
    func didFail(toReceive interstitialAd: CaulyInterstitialAd!, errorCode: Int32, errorMsg: String!) {
        APLogger.error("Cauly Interstitial Error: \(errorMsg ?? "Cauly error")")
        delegate?.interstitialLoadFail(error: .nextMediation, errorMessage: errorMsg)
    }
    
    func didClose(_ interstitialAd: CaulyInterstitialAd!) {
        delegate?.interstitialClosed(message: "closed Cauly Interstitial")
    }
    
    func willShow(_ interstitialAd: CaulyInterstitialAd!) {
        delegate?.interstitialShowSuccess(message: "show Cauly Interstitial")
    }
}
