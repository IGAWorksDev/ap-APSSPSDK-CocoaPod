import Foundation
import APSSPSDK

extension APSSPAds {
    public func GAMisSupportBanner() -> Bool { APSSPMediationCompany.GAM.isSupportBanner }
    public func GAMisSupportNative() -> Bool { APSSPMediationCompany.GAM.isSupportNative }
    public func GAMisSupportInterstitial() -> Bool { APSSPMediationCompany.GAM.isSupportInterstitial }
    public func GAMisSupportInterstitialVideo() -> Bool { APSSPMediationCompany.GAM.isSupportInterstitialVideo }
    public func GAMisSupportRewardVideo() -> Bool { APSSPMediationCompany.GAM.isSupportRewardVideo }
}
