//
//  PlaceInfo.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

struct PlaceInfo: Equatable {
    /// title은 장소가 있으면 건물명, 없으면 도로명으로 대체
    let title: String
    let jibunAddress: String
    let roadAddress: String
    let phoneNumber: String
}
