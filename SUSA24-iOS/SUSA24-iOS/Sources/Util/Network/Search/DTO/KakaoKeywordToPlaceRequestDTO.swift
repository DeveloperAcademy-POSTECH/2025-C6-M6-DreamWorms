//
//  KakaoKeywordToPlaceRequestDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Foundation

nonisolated struct KakaoKeywordToPlaceRequestDTO: Encodable, Sendable {
    /// 검색을 원하는 질의어
    let query: String
    /// 중심 좌표의 X값 혹은 경도(longitude)
    let x: String?
    /// 중심 좌표의 Y값 혹은 위도(latitude)
    let y: String?
    /// 중심 좌표부터의 반경거리(단위: 미터). 최대 20000
    let radius: Int?
    /// 결과 페이지 번호. 1~45 사이 값 (기본값: 1)
    let page: Int?
    /// 한 페이지에 보여질 문서의 개수. 1~15 사이 값 (기본값: 15)
    let size: Int?
}

