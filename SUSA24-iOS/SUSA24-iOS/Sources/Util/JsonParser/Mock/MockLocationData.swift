//
//  MockLocationData.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/16/25.
//

import Foundation

// MARK: - Mock Data Models

/// Mock 데이터의 위치 정보를 나타내는 구조체
struct MockLocationData: Codable {
    let timestamp: String
    let message: String?
    let address: String?
    let notes: String?
}

/// Mock 데이터 전체를 나타내는 구조체
struct MockDataContainer: Codable {
    let locations: [MockLocationData]
}

// MARK: - Mock Data Loader

/// 목데이터 JSON 파일을 로드하고 파싱하는 서비스
struct MockDataLoader {
    // MARK: - Error Types
    
    enum LoadError: LocalizedError {
        case fileNotFound(String)
        case decodingFailed(Error)
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case let .fileNotFound(filename):
                "목데이터 파일을 찾을 수 없습니다: \(filename)"
            case let .decodingFailed(error):
                "데이터 파싱 실패: \(error.localizedDescription)"
            case .invalidData:
                "유효하지 않은 데이터 형식입니다"
            }
        }
    }
    
    // MARK: - Properties
    
    private let filename: String
    
    // MARK: - Initialization
    
    init(filename: String = "mock_locations.json") {
        self.filename = filename
    }
    
    // MARK: - Load Methods
    
    /// JSON 파일에서 목데이터를 로드합니다
    /// - Returns: 파싱된 목데이터 배열
    /// - Throws: 파일을 찾을 수 없거나 파싱에 실패한 경우 에러
    func loadMockData() async throws -> [MockLocationData] {
        // Bundle에서 파일 찾기
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""),
                                        withExtension: "json")
        else {
            throw LoadError.fileNotFound(filename)
        }
        
        do {
            // 파일 데이터 읽기
            let data = try Data(contentsOf: url)
            
            // JSON 디코딩
            let decoder = JSONDecoder()
            let container = try decoder.decode(MockDataContainer.self, from: data)
            
            print(" [MockDataLoader] \(container.locations.count)개의 목데이터 로드 완료")
            return container.locations
            
        } catch let error as DecodingError {
            throw LoadError.decodingFailed(error)
        } catch {
            throw error
        }
    }
    
    /// 목데이터를 LocationEntity로 변환할 수 있는 형태로 반환합니다
    /// - Parameter caseId: 연결할 케이스 ID
    /// - Returns: (timestamp, address, notes) 튜플 배열
    func loadMockDataForCase(caseId _: UUID) async throws -> [(Date, String, String)] {
        let mockData = try await loadMockData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var results: [(Date, String, String)] = []
        
        for location in mockData {
            // timestamp 파싱
            guard let date = dateFormatter.date(from: location.timestamp) else {
                print("⚠️ [MockDataLoader] 날짜 파싱 실패: \(location.timestamp)")
                continue
            }
            
            // address가 있는 경우만 포함
            guard let address = location.address, !address.isEmpty else {
                continue
            }
            
            let notes = location.notes ?? ""
            results.append((date, address, notes))
        }
        
        print("✅ [MockDataLoader] \(results.count)개의 유효한 위치 데이터 변환 완료")
        return results
    }
}
