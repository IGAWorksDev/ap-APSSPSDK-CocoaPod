//
//  AdFitMediationUnifiedNativeAdView.swift
//  MediationAdFit
//
//  Created by Odin on 2026/07/06.
//

import UIKit
  import AdFitSDK
  import APSSPSDK


  // MARK: - Custom 연동용 내부 래퍼 뷰

  private final class AdFitCustomNativeAdView: UIView, AdFitNativeAdRenderable {

      private weak var viewBinder: APSSPMediationViewBinder?
      private let mediaView = AdFitMediaView()

      init(viewBinder: APSSPMediationViewBinder) {
          self.viewBinder = viewBinder
          super.init(frame: .zero)
          setupMediaView()
      }

      required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

      private func setupMediaView() {
          guard let container = viewBinder?.mediaContainerView else { return }

          container.subviews.forEach { $0.removeFromSuperview() }
          mediaView.translatesAutoresizingMaskIntoConstraints = false
          container.addSubview(mediaView)

          NSLayoutConstraint.activate([
              mediaView.topAnchor.constraint(equalTo: container.topAnchor),
              mediaView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
              mediaView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
              mediaView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
          ])
      }

      // MARK: - AdFitNativeAdRenderable

      func adTitleLabel() -> UILabel? { viewBinder?.titleLabel }
      func adBodyLabel() -> UILabel? { viewBinder?.bodyLabel }
      func adCallToActionButton() -> UIButton? { viewBinder?.ctaButton }
      func adProfileNameLabel() -> UILabel? { viewBinder?.adFitProfileNameLabel }
      func adProfileIconView() -> UIImageView? { viewBinder?.adFitProfileIconView }
      func adMediaView() -> AdFitMediaView? { mediaView }
  }


  // MARK: - AdFitMediationUnifiedNativeAdView

  final class AdFitMediationUnifiedNativeAdView: UIView {

      weak var delegate: APSSPUnifiedNativeAdapterDelegate?

      private let placementId: String
      private weak var rootViewController: UIViewController?
      private let viewBinder: APSSPMediationViewBinder
      private let config: APSSPNativeAdConfig?

      private var nativeAdLoader: AdFitNativeAdLoader?
      private let bizboardTemplate = BizBoardTemplate()
      private var customNativeAdView: AdFitCustomNativeAdView?


      init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?) {
          self.placementId = placementId
          self.rootViewController = rootViewController
          self.viewBinder = viewBinder
          self.config = config
          super.init(frame: .zero)
      }

      required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

      deinit { APLogger.debug("AdFitMediationUnifiedNativeAdView deinit") }

      func load() {
          guard !placementId.isEmpty else {
              delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "AdFit placementId is empty")
              return
          }

          nativeAdLoader = AdFitNativeAdLoader(clientId: placementId)
          nativeAdLoader?.delegate = self
          nativeAdLoader?.loadAd()
      }

      func stop() {
          nativeAdLoader?.delegate = nil
          nativeAdLoader = nil
          customNativeAdView = nil
      }
  }

  extension AdFitMediationUnifiedNativeAdView: AdFitNativeAdLoaderDelegate, AdFitNativeAdDelegate {

      func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
          let useBizBoard = config?.adFitBizBoard ?? false

          var visibleKeys = Set<String>()

          if useBizBoard {
              // BizBoard 템플릿 사용
              nativeAd.infoIconRightConstant = -16
              nativeAd.bind(bizboardTemplate)
              nativeAd.rootViewController = rootViewController
              nativeAd.delegate = self
              bizboardTemplate.autoresizingMask = .flexibleWidth
              viewBinder.insertMediaView(bizboardTemplate)
          } else {
              // Custom 연동 - MediationViewBinder 사용
              customNativeAdView = AdFitCustomNativeAdView(viewBinder: viewBinder)
              nativeAd.infoIconRightConstant = -16
              nativeAd.bind(customNativeAdView!)
              nativeAd.rootViewController = rootViewController
              nativeAd.delegate = self

              // AdFit 전용 옵셔널 뷰 visible 처리
              if viewBinder.adFitProfileNameLabel != nil {
                  visibleKeys.insert("adFitProfileName")
              }
              if viewBinder.adFitProfileIconView != nil {
                  visibleKeys.insert("adFitProfileIcon")
              }
          }

          viewBinder.hideOptionalViews(except: visibleKeys)
          delegate?.unifiedNativeLoadSuccess()
      }

      func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
          delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
      }

      func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
          delegate?.unifiedNativeClicked(message: "AdFit UnifiedNative clicked")
      }
  }
