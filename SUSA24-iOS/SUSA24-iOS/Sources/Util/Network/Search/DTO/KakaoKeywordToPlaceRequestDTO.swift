//
//  KakaoKeywordToPlaceRequestDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/6/25.
//

import Foundation

/// 키워드로 장소를 검색하기 위한 요청 DTO
struct KakaoKeywordToPlaceRequestDTO {
    /// 검색을 원하는 질의어
    let query: String
    /// 중심 좌표의 경도(longitude)
    let x: String?
    /// 중심 좌표의 위도(latitude)
    let y: String?
    /// 중심 좌표부터의 반경거리(단위: 미터). 최대 20000
    let radius: Int?
    /// 결과 페이지 번호. 1~45 사이 값 (기본값: 1)
    let page: Int?
    /// 한 페이지에 보여질 문서의 개수. 1~15 사이 값 (기본값: 15)
    let size: Int?
}
