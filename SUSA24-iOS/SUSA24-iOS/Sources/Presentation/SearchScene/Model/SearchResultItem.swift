//
//  SearchResultItem.swift
//  SUSA24-iOS
//
//  Created by Assistant on 11/8/25.
//

/// 검색 결과 항목 데이터 모델입니다.
struct SearchResultItem: Identifiable, Equatable {
    let id: String
    let title: String
    let jibunAddress: String
    let roadAddress: String
    let phoneNumber: String
    let latitude: Double?
    let longitude: Double?
}
