import Foundation
import APSSPSDK

extension APSSPAds {
    public func NAMisSupportBanner() -> Bool { APSSPMediationCompany.NAM.isSupportBanner }
    public func NAMisSupportNative() -> Bool { APSSPMediationCompany.NAM.isSupportNative }
    public func NAMisSupportInterstitial() -> Bool { APSSPMediationCompany.NAM.isSupportInterstitial }
    public func NAMisSupportInterstitialVideo() -> Bool { APSSPMediationCompany.NAM.isSupportInterstitialVideo }
    public func NAMisSupportRewardVideo() -> Bool { APSSPMediationCompany.NAM.isSupportRewardVideo }
}
