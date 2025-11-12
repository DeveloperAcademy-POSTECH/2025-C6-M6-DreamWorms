//
//  CellStationLoader.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

import Foundation

/// 기지국 데이터 로더
enum CellStationLoader {
    /// JSON 파일에서 기지국 데이터를 로드합니다
    /// - Parameter filename: JSON 파일명 (기본값: pohang_cell_station_data.json)
    /// - Returns: CellStation 도메인 모델 배열
    /// - Throws: JSONLoaderError
    static func loadFromJSON(filename: String = "pohang_cell_station_data.json") async throws -> [CellStation] {
        let root = try JSONLoader.load(filename, as: CellStationRoot.self)
        return root.sheet1.map { CellStation(from: $0) }
    }
}
