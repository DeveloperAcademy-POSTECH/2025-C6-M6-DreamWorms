//
//  MapFilterType.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

/// 지도 화면에서 사용하는 필터 타입입니다.
enum MapFilterType: String, CaseIterable {
    case cellStationRange = "기지국 범위"
    case visitFrequency = "누적 빈도"
    case recentBaseStation = "최근 기지국"
    
    var iconName: String {
        switch self {
        case .cellStationRange:
            "icn_cell_range_filter"
        case .visitFrequency:
            "icn_visit_frequency_filter"
        case .recentBaseStation:
            "icn_cell_station_filter"
        }
    }
}
