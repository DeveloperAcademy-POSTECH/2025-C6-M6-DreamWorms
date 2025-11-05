//
//  KakaoCoordToLocationResponseDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Foundation

nonisolated struct KakaoCoordToLocationResponseDTO: Decodable, Sendable {
    let meta: KakaoMeta
    let documents: [KakaoDocument]
}

struct KakaoMeta: Decodable, Sendable {
    let totalCount: Int
}

struct KakaoDocument: Decodable, Sendable {
    let address: KakaoAddress?
    let roadAddress: KakaoRoadAddress?
}

struct KakaoAddress: Decodable, Sendable {
    /// 전체 지번 주소
    let addressName: String
    
    /// 지역 1 depth, 시도 단위(예: 서울특별시)
    let region1depthName: String?
    
    /// 지역 2 depth, 시군구 단위(예: 강남구)
    let region2depthName: String?
    
    /// 지역 3 depth, 동 단위(예: 삼성동)
    let region3depthName: String?
    
    /// 지역 4 depth, region_type이 H인 경우에만 존재 (예: 상세주소)
    let region4depthName: String?
    
    /// 지역 타입
    let regionType: String?
    
    /// 행정 코드
    let code: String?
    
    /// X 좌표 혹은 경도(longitude)
    let x: String?
    
    /// Y 좌표 혹은 위도(latitude)
    let y: String?
    
    /// 산 여부 (Y/N)
    let mountainYn: String?
    
    /// 지번 본번
    let mainAddressNo: String?
    
    /// 지번 부번
    let subAddressNo: String?
    
    /// 우편번호
    let zipCode: String?
}

struct KakaoRoadAddress: Decodable, Sendable {
    /// 전체 도로명 주소
    let addressName: String
    
    /// 지역 1 depth, 시도 단위(예: 서울특별시)
    let region1depthName: String?
    
    /// 지역 2 depth, 시군구 단위(예: 강남구)
    let region2depthName: String?
    
    /// 지역 3 depth, 동 단위(예: 삼성동)
    let region3depthName: String?
    
    /// 지역 4 depth, region_type이 H인 경우에만 존재 (예: 상세주소)
    let region4depthName: String?
    
    /// 지역 타입
    let regionType: String?
    
    /// 행정 코드
    let code: String?
    
    let x: String?
    let y: String?
    
    /// 건물명
    let buildingName: String?
    
    /// 건물 상세 주소
    let buildingCode: String?
    
    /// 도로명
    let roadName: String?
    
    /// 지하 여부 (Y/N)
    let undergroundYn: String?
    
    /// 건물 본번
    let mainBuildingNo: String?
    
    /// 건물 부번
    let subBuildingNo: String?
    
    /// 우편번호
    let zoneNo: String?
}

