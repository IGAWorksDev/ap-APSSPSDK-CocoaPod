import Foundation
import APSSPSDK

extension APSSPAds {
    public func AdMobisSupportBanner() -> Bool { APSSPMediationCompany.AdMob.isSupportBanner }
    public func AdMobisSupportNative() -> Bool { APSSPMediationCompany.AdMob.isSupportNative }
    public func AdMobisSupportInterstitial() -> Bool { APSSPMediationCompany.AdMob.isSupportInterstitial }
    public func AdMobisSupportInterstitialVideo() -> Bool { APSSPMediationCompany.AdMob.isSupportInterstitialVideo }
    public func AdMobisSupportRewardVideo() -> Bool { APSSPMediationCompany.AdMob.isSupportRewardVideo }
}
