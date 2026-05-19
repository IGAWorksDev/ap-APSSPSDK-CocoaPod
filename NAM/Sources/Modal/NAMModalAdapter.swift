//
//  NAMModalAdapter.swift
//  MediationNAM
//

import UIKit
import APSSPSDK
import GFPSDK


final public class NAMModalAdapter: NSObject, APSSPModalAdapterProtocol {

    weak public var delegate: APSSPModalAdapterDelegate?
    weak public var rootViewController: UIViewController?

    private let unitID: String
    private weak var modalRootView: UIView?
    private var adGravity: Int
    private var closeBtnType: Int

    private var adLoader: GFPAdLoader?
    private var bannerView: GFPBannerView?
    private var closeLabel: UILabel?

    required public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        self.unitID = placementDic[APSSPPlacementKey.namUnitId.rawValue] ?? ""
        self.rootViewController = rootViewController
        self.modalRootView = info["modalRootView"] as? UIView
        self.adGravity = info["adGravity"] as? Int ?? 0
        self.closeBtnType = info["closeBtnType"] as? Int ?? 0
        super.init()
    }

    public func connectDelegate(delegate: APSSPModalAdapterDelegate) {
        self.delegate = delegate
    }

    public func disconnectDelegate() {
        delegate = nil
    }

    public func loadAd() {
        guard let rootViewController else {
            delegate?.modalLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }

        let adParam = GFPAdParam()
        adLoader = GFPAdLoader(unitID: unitID, rootViewController: rootViewController, adParam: adParam)

        let bannerOption = GFPAdBannerOptions()
        bannerOption.layoutType = .fluidWidth
        adLoader?.setBannerDelegate(self, bannerOptions: bannerOption)
        adLoader?.delegate = self

        APLogger.debug("Start NAM Modal load, UnitID: \(unitID)")
        adLoader?.loadAd()
    }

    public func showAd() {
        guard let modalRootView, let bannerView else {
            delegate?.modalShowFail(errorMessage: "No ad loaded")
            return
        }

        APLogger.debug("NAMModalAdapter showAd — bannerView frame: \(bannerView.frame)")

        let bannerWidth = max(bannerView.frame.size.width, UIScreen.main.bounds.width)
        let bannerHeight = max(bannerView.frame.size.height, 50)
        let bottomAreaHeight: CGFloat = {
            if #available(iOS 11.0, *) {
                return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            }
            return 0
        }()

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        modalRootView.addSubview(bannerView)

        // width / height — 실제 bannerView 크기 사용
        bannerView.widthAnchor.constraint(equalToConstant: bannerWidth).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: modalRootView.centerXAnchor).isActive = true

        // 닫기 버튼
        let label = UILabel()
        label.text = closeBtnType == 1 ? "오늘 그만 보기" : "광고 닫기"
        label.textColor = .white
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        label.addGestureRecognizer(tap)
        modalRootView.addSubview(label)
        closeLabel = label

        label.trailingAnchor.constraint(equalTo: modalRootView.trailingAnchor, constant: -16).isActive = true

        if adGravity == 1 {
            // Center
            bannerView.centerYAnchor.constraint(equalTo: modalRootView.centerYAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: modalRootView.centerYAnchor, constant: -(bannerHeight / 2) - 20).isActive = true
        } else {
            // Bottom
            bannerView.bottomAnchor.constraint(equalTo: modalRootView.bottomAnchor, constant: -bottomAreaHeight).isActive = true
            label.bottomAnchor.constraint(equalTo: modalRootView.bottomAnchor, constant: -(bannerHeight + 5 + bottomAreaHeight)).isActive = true
        }

        modalRootView.isHidden = false
        delegate?.modalShowSuccess()
    }

    public func stop() {
        bannerView?.removeFromSuperview()
        closeLabel?.removeFromSuperview()
        modalRootView?.isHidden = true
        adLoader = nil
        bannerView = nil
    }

    // MARK: - Close

    @objc private func closeTapped() {
        stop()
        delegate?.modalClosed()
    }
}


// MARK: - GFP Delegate
extension NAMModalAdapter: GFPAdLoaderDelegate, GFPBannerViewDelegate {

    public func adLoader(_ unifiedAdLoader: GFPAdLoader!, didReceiveBannerAd bannerView: GFPBannerView!) {
        self.bannerView = bannerView
        delegate?.modalLoadSuccess()
    }

    public func adLoader(_ unifiedAdLoader: GFPAdLoader!, didFailWithError error: GFPError!, responseInfo: GFPLoadResponseInfo!) {
        APLogger.error("NAM Modal Error: \(error?.description ?? "unknown")")
        delegate?.modalLoadFail(error: .nextMediation, errorMessage: error?.description)
    }

    public func bannerAdWasSeen(_ bannerView: GFPBannerView) {
        // impression은 ModalAdLoader에서 trackMediationImp으로 처리
    }

    public func bannerAdWasClicked(_ bannerView: GFPBannerView) {
        delegate?.modalClicked()
    }

    public func bannerShouldUnload(_ bannerView: GFPBannerView) {}
    public func bannerAdWasMuted(_ bannerView: GFPBannerView) {}
}
