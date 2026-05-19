import Foundation
import APSSPSDK

extension APSSPAds {
    public func mezzoIsSupportBanner() -> Bool { APSSPMediationCompany.MezzoMedia.isSupportBanner }
    public func mezzoIsSupportNative() -> Bool { APSSPMediationCompany.MezzoMedia.isSupportNative }
    public func mezzoIsSupportInterstitial() -> Bool { APSSPMediationCompany.MezzoMedia.isSupportInterstitial }
    public func mezzoIsSupportInterstitialVideo() -> Bool { APSSPMediationCompany.MezzoMedia.isSupportInterstitialVideo }
    public func mezzoIsSupportRewardVideo() -> Bool { APSSPMediationCompany.MezzoMedia.isSupportRewardVideo }
}
