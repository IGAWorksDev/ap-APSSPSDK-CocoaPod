//
//  InMobiMediationNativeAdView.swift
//  MediationInMobi
//

import UIKit
import APSSPSDK
import InMobiSDK


@objc
public final class APSSPInMobiNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var inMobiNativeAdView: UIView?
    @objc public var adTitleLabel: UILabel?
    @objc public var adDescriptionLabel: UILabel?
    @objc public var adIcon: UIImageView?
    @objc public var adCtaTextLabel: UILabel?
    @objc public var adRatingLabel: UILabel?
    @objc public var advertiserNameLabel: UILabel?
    @objc public var adChoice: UIImageView?
}


final class InMobiMediationNativeAdView: UIView {

    weak var delegate: APSSPNativeViewAdapterDelegate?

    var inMobiRenderer: APSSPInMobiNativeAdRenderer?

    private var nativeAd: IMNative?

    private let placementId: String

    private let rootViewController: UIViewController?


    init(placementId: String, rootViewController: UIViewController?, render: AnyObject) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        super.init(frame: .zero)

        guard let render = render as? APSSPInMobiNativeAdRenderer else { return }
        inMobiRenderer = render
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("InMobi Native placementId is empty")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard rootViewController != nil else {
            APLogger.error("NativeAd rootViewController is nil")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }

        let pid = Int64(placementId) ?? 0
        APLogger.debug("Start InMobi Native load, placementId: \(pid)")

        nativeAd = IMNative(placementId: pid, delegate: self)
        nativeAd?.load()
    }

    func stop() {
        nativeAd?.delegate = nil
        nativeAd = nil
    }

    private func setupData() {
        guard let inMobiRenderer, let nativeAd else { return }
        inMobiRenderer.adTitleLabel?.text = nativeAd.adTitle
        inMobiRenderer.adDescriptionLabel?.text = nativeAd.adDescription
        inMobiRenderer.adIcon?.image = nativeAd.adIcon?.imageview?.image
        inMobiRenderer.adCtaTextLabel?.text = nativeAd.adCtaText
        inMobiRenderer.adRatingLabel?.text = nativeAd.adRating
        inMobiRenderer.advertiserNameLabel?.text = nativeAd.advertiserName
        if let adChoiceView = nativeAd.adChoice {
            inMobiRenderer.adChoice?.image = adChoiceView.image
            inMobiRenderer.adChoice?.isUserInteractionEnabled = true
        }
    }

    private func registerTracking() {
        guard let inMobiRenderer, let parentView = inMobiRenderer.inMobiNativeAdView else { return }
        let builder = IMNativeViewData.Builder(adParentView: parentView)
        if let title = inMobiRenderer.adTitleLabel { builder.setTitleView(title) }
        if let desc = inMobiRenderer.adDescriptionLabel { builder.setDescriptionView(desc) }
        if let cta = inMobiRenderer.adCtaTextLabel { builder.setCTAView(cta) }
        if let icon = inMobiRenderer.adIcon { builder.setIconView(icon) }
        if let rating = inMobiRenderer.adRatingLabel { builder.setRatingView(rating) }
        if let advertiser = inMobiRenderer.advertiserNameLabel { builder.setAdvertiserView(advertiser) }
        nativeAd?.registerViewForTracking(builder.build())
    }
}


// MARK: - IMNativeDelegate
extension InMobiMediationNativeAdView: IMNativeDelegate {
    func nativeDidFinishLoading(_ native: IMNative) {
        setupData()
        registerTracking()
        delegate?.nativeLoadSuccess()
    }

    func native(_ native: IMNative, didFailToLoadWithError error: IMRequestStatus) {
        APLogger.error("InMobi Native Error: \(error.localizedDescription)")
        delegate?.nativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }

    func nativeAdImpressed(_ native: IMNative) {
        delegate?.nativeImpression(message: "InMobi NativeView is impression")
    }

    func native(_ native: IMNative, didInteractWithParams params: [String: Any]?) {
        delegate?.nativeClicked(message: "InMobi NativeView is clicked")
    }
}
