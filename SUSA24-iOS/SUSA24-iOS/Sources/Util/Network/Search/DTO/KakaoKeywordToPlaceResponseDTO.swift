//
//  KakaoKeywordToPlaceResponseDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Foundation

struct KakaoKeywordToPlaceResponseDTO: Decodable, Sendable {
    let meta: KakaoKeywordMeta
    let documents: [KakaoPlaceDocument]
}

struct KakaoKeywordMeta: Decodable, Sendable {
    /// 검색어에 검색된 문서 수
    let totalCount: Int
    /// total_count 중 노출 가능 문서 수
    let pageableCount: Int
    /// 현재 페이지가 마지막 페이지인지 여부
    let isEnd: Bool
}

struct KakaoPlaceDocument: Decodable, Sendable {
    /// 장소명
    let placeName: String?
    /// 카테고리 이름
    let categoryName: String?
    /// 카테고리 그룹 코드
    let categoryGroupCode: String?
    /// 카테고리 그룹명
    let categoryGroupName: String?
    /// 전화번호
    let phone: String?
    /// 전체 지번 주소
    let addressName: String?
    /// 전체 도로명 주소
    let roadAddressName: String?
    /// X 좌표값 혹은 longitude
    let x: String?
    /// Y 좌표값 혹은 latitude
    let y: String?
    /// 장소 ID
    let id: String?
    /// 장소 상세페이지 URL
    let placeUrl: String?
    /// 거리(단위: 미터)
    let distance: String?
}

