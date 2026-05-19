//
//  MessageManager.swift
//  ADPlusSampleSwift
//
//  Created by LeeSeungwoo on 2023/03/29.
//

import Foundation
import LibADPlus

class MessageManager:NSObject {
    static func getResponseString(FromCode code:ADMZResponseStatusType,fromFunction functionString:String) -> String?{
        switch (code) {
            case .AdSuccess: do {
                return functionString.appending(" - 성공")
            }
            case .AdClick: do {
                return functionString.appending(" - 광고 클릭")
            }
                
            case .AdClose: do {
                return functionString.appending(" - 광고 닫기")
            }
            case .AdNotError: do {
                return functionString.appending(" - 광고 없음(No Ads)")
            }
            case .AdPassbackError: do {
                return functionString.appending(" - Sync 모드 필요 (패스백)")
            }
            case .AdTimeoutError: do {
                return functionString.appending(" - Timeout")
            }
            case .AdParsingError: do {
                return functionString.appending(" - 파싱 에러")
            }
            case .AdDuplicateError: do {
                return functionString.appending(" - 중복 호출 에러")
            }
            case .AdError: do {
                return functionString.appending(" - 에러")
            }
            case .BrowserError: do {
                return functionString.appending(" - Browser Error")
            }
            case .AdNotExistError: do {
                return functionString.appending(" - 존재하지 않는 요청 에러")
            }
            case .AdAppStoreUrlError: do {
                return functionString.appending(" - 앱 Store URL 미입력")
            }
            case .AdIDError: do {
                return functionString.appending(" - 사업자/미디어/섹션 코드 미존재")
            }
            case .AdTargetAreaError: do {
                return functionString.appending(" - 광고영역크기 에러")
            }
            case .AdUserAgeLevelError: do {
                return functionString.appending(" - User age level 에러")
            }
            case .AdReloadTimeError: do {
                return functionString.appending(" - 광고 재호출(Reload) 에러")
            }
            case .AdNetworkError: do {
                return functionString.appending(" - 네트워크 에러")
            }
            case .AdFileError: do {
                return functionString.appending(" - 광고물 파일 형식 에러")
            }
            case .AdCreativeError: do {
                return functionString.appending(" - 광고물 요청 실패(Timeout)")
            }
            case .VideoAdStart: do {
                return functionString.appending(" - 비디오 광고 시작")
            }
            case .VideoAdSkip: do {
                return functionString.appending(" - 비디오 광고 SKIP")
            }
            case .AdDidImpression: do {
                return functionString.appending(" - 광고 노출 시작")
            }
            case .VideoAdFirstQ: do {
                return functionString.appending(" - 비디오 1/4 재생")
            }
            case .VideoAdMidQ: do {
                return functionString.appending(" - 비디오 2/4 재생")
            }
            case .VideoAdThirdQ: do {
                return functionString.appending(" - 비디오 3/4 재생")
            }
            case .VideoAdComplete: do {
                return functionString.appending(" - 비디오 광고 재생완료")
            }
            case .AdVideoOptError: do {
                return functionString.appending(" - 비디오 옵션 에러")
            }
            case .AdStartError: do {
                return functionString.appending(" - Start이벤트 미완료 상태")
            }
            case .AdUnknownError: do {
                return functionString.appending(" - 알수없는 오류")
            }
            default: do {
                return functionString.appending(" - 미지정 이벤트")
            }
        }
    }
    
    
    static func commonMessage(FromCode code:ADMZResponseStatusType,fromFunction functionString:String) {
        let space = "-------------"
        var log =  "\n\(space)Response Code = \(code.rawValue)"

        if let str = getResponseString(FromCode: code, fromFunction: functionString), !str.isEmpty {
            log = log.appending("\n\(str)")
        }
      print("Log = \(log)")
    }
}
