import Foundation
import APSSPSDK

extension APSSPAds {
    public func inMobiisSupportBanner() -> Bool { APSSPMediationCompany.InMobi.isSupportBanner }
    public func inMobiisSupportNative() -> Bool { APSSPMediationCompany.InMobi.isSupportNative }
    public func inMobiisSupportInterstitial() -> Bool { APSSPMediationCompany.InMobi.isSupportInterstitial }
    public func inMobiisSupportInterstitialVideo() -> Bool { APSSPMediationCompany.InMobi.isSupportInterstitialVideo }
    public func inMobiisSupportRewardVideo() -> Bool { APSSPMediationCompany.InMobi.isSupportRewardVideo }
}
