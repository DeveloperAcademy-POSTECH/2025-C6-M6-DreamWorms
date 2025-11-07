//
//  NetworkHeader.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Alamofire
import Foundation

enum NetworkHeader {
    /// 카카오 API 공통 헤더
    static var kakaoHeaders: HTTPHeaders {
        [
            NetworkConstant.KakaoAPIHeaderKey.authorization: "KakaoAK \(Config.kakaoRestAPIKey)",
        ]
    }
    
    /// 네이버 API 공통 헤더
    static var naverHeaders: HTTPHeaders {
        [
            NetworkConstant.NaverAPIHeaderKey.clientID: Config.naverMapClientID,
            NetworkConstant.NaverAPIHeaderKey.clientSecret: Config.naverMapClientSecret,
        ]
    }
}
