//
//  KakaoCoordToLocationRequestDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/6/25.
//

import Foundation

/// 좌표로 주소 정보를 조회하기 위한 요청 DTO
struct KakaoCoordToLocationRequestDTO {
    /// 경도(Longitude)
    let x: String
    /// 위도(Latitude)
    let y: String
    /// 입력 좌표계 (기본값: WGS84)
    let inputCoord: String?
}
