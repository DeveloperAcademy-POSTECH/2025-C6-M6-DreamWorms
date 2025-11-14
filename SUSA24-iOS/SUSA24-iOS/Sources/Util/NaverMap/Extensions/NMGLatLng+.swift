//
//  NMGLatLng+.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

import NMapsMap

extension NMGLatLng {
    /// 네이버 지도 좌표를 카카오 API 요청 DTO로 변환합니다.
    /// - Note: 네이버 지도는 (위도, 경도) 순서이지만, 카카오 API는 (경도, 위도) 순서를 사용합니다.
    /// - Parameter inputCoord: 입력 좌표계 (기본값: WGS84)
    /// - Returns: 카카오 API 요청 DTO
    func toKakaoRequestDTO(inputCoord: String? = "WGS84") -> KakaoCoordToLocationRequestDTO {
        KakaoCoordToLocationRequestDTO(
            x: String(lng), // 경도 (네이버 lng → 카카오 x)
            y: String(lat), // 위도 (네이버 lat → 카카오 y)
            inputCoord: inputCoord
        )
    }
}
