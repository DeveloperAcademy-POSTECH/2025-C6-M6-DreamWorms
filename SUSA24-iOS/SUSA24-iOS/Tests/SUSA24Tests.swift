//
//  SUSA24Tests.swift
//  SUSA24Tests
//
//  Created by mini on 10/29/25.
//

import CoreData
@testable import SUSA24_iOS
import XCTest

@MainActor
final class SUSA24Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    @MainActor func testJSONLoaderSync() throws {
        // Given: 테스트용 간단한 모델
        struct TestModel: Decodable {
            let address: String
            let pointLatitude: Double
            let pointLongitude: Double
        }
        
        // When: JSON 파일 로드
        let data: [TestModel] = try JSONLoader.load("pin_smaple.json")
        
        // Then: 데이터가 정상적으로 로드되었는지 확인
        XCTAssertFalse(data.isEmpty, "데이터가 비어있으면 안됨")
        XCTAssertEqual(data.count, 21, "21개 항목이 있어야 함")
        
        // 첫 번째 항목 검증
        let firstItem = try XCTUnwrap(data.first, "첫 번째 항목이 존재해야 함")
        XCTAssertFalse(firstItem.address.isEmpty, "주소가 비어있으면 안됨")
        XCTAssertNotEqual(firstItem.pointLatitude, 0, "위도가 0이면 안됨")
        XCTAssertNotEqual(firstItem.pointLongitude, 0, "경도가 0이면 안됨")
        
        print("동기 로딩 성공: \(data.count)개")
        print("첫 항목: \(firstItem.address)")
    }
    
    func testJSONLoaderMultipleFiles() async throws {
        // Given
        struct SimpleModel: Decodable {
            let address: String
        }
        
        // When: 여러 파일을 동시에 로드
        async let pins = JSONLoader.loadAsync("pin_smaple.json", as: [SimpleModel].self)
        async let stations = JSONLoader.loadAsync("pohang_base_station_sample.json", as: [SimpleModel].self)
        
        let (pinsData, stationsData) = try await (pins, stations)
        
        // Then
        XCTAssertFalse(pinsData.isEmpty, "핀 데이터가 비어있으면 안됨")
        XCTAssertFalse(stationsData.isEmpty, "기지국 데이터가 비어있으면 안됨")
        
        print("동시 로딩 성공")
        print("핀: \(pinsData.count)개")
        print("기지국: \(stationsData.count)개")
    }
    
    // MARK: - URLBuilder Test
    
    func testURLBuilder() throws {
        // Given
        let baseURL = URLConstant.kakaoKeywordToPlaceURL
        let parameters: [String: Any?] = [
            "query": "카페",
            "x": "127.0",
            "y": "37.5",
            "radius": 1000,
            "page": 1,
            "size": 15,
        ]
        
        // When
        let result = try URLBuilder.build(baseURL: baseURL, parameters: parameters)
        
        // Then
        print("✅ URLBuilder 결과:")
        print(result)
        XCTAssertTrue(result.starts(with: baseURL))
    }
    
    // MARK: VWorld CCTV BOX 검색 API 테스트
    
    @MainActor
    func testFetchCCTVByBox() async throws {
        // Given
        let requestDTO = VWorldBoxRequestDTO(
            minLng: 129.36,
            minLat: 36.02,
            maxLng: 129.38,
            maxLat: 36.04,
            size: 10,
            page: 1
        )
        
        // When
        let response = try await VWorldService().fetchCCTVByBox(requestDTO)
        
        // Then
        var logOutput = "✅ VWorld CCTV BOX 검색 성공\n"
        logOutput += "검색 영역: (\(requestDTO.minLng), \(requestDTO.minLat)) ~ (\(requestDTO.maxLng), \(requestDTO.maxLat))\n"
        logOutput += "결과 개수: \(response.features.count)\n"
        logOutput += "========================================\n"
        for (index, feature) in response.features.enumerated() {
            logOutput += "\n[CCTV \(index + 1)]\n"
            logOutput += "  ID: \(feature.id)\n"
            logOutput += "  이름: \(feature.properties.cctvname)\n"
            logOutput += "  위치: \(feature.properties.locate)\n"
            logOutput += "  좌표: (\(feature.geometry.coordinates[0]), \(feature.geometry.coordinates[1]))\n"
        }
        logOutput += "========================================\n"
        
        print(logOutput)
        let attachment = XCTAttachment(string: logOutput)
        attachment.lifetime = .keepAlways
        add(attachment)
        
        XCTAssertFalse(response.features.isEmpty)
    }
    
    // MARK: VWorld CCTV Polygon 검색 API 테스트
    
    @MainActor
    func testFetchCCTVByPolygon() async throws {
        // Given
        let coordinates = [
            MapCoordinate(latitude: 36.02, longitude: 129.36),
            MapCoordinate(latitude: 36.02, longitude: 129.38),
            MapCoordinate(latitude: 36.04, longitude: 129.37),
        ]
        let requestDTO = VWorldPolygonRequestDTO(coordinates: coordinates, size: 10, page: 1)
        
        // When
        let response = try await VWorldService().fetchCCTVByPolygon(requestDTO)
        
        // Then
        var logOutput = "✅ VWorld CCTV Polygon 검색 성공\n"
        logOutput += "검색 좌표:\n"
        for (index, coord) in coordinates.enumerated() {
            logOutput += "  \(index + 1). (\(coord.longitude), \(coord.latitude))\n"
        }
        logOutput += "결과 개수: \(response.features.count)\n"
        logOutput += "========================================\n"
        for (index, feature) in response.features.enumerated() {
            logOutput += "\n[CCTV \(index + 1)]\n"
            logOutput += "  ID: \(feature.id)\n"
            logOutput += "  이름: \(feature.properties.cctvname)\n"
            logOutput += "  위치: \(feature.properties.locate)\n"
            logOutput += "  좌표: (\(feature.geometry.coordinates[0]), \(feature.geometry.coordinates[1]))\n"
        }
        logOutput += "========================================\n"
        
        print(logOutput)
        let attachment = XCTAttachment(string: logOutput)
        attachment.lifetime = .keepAlways
        add(attachment)
        
        XCTAssertFalse(response.features.isEmpty)
    }
}

// MARK: Location Repository Tests

@MainActor
final class LocationRepositoryTests: XCTestCase {
    var context: NSManagedObjectContext!
    var repository: LocationRepository!
    var caseId: UUID!
    var suspect: SuspectEntity!
    
    override func setUpWithError() throws {
        // In-memory CoreData 설정
        let container = NSPersistentContainer(name: "SUSA24_iOS")
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        container.loadPersistentStores { _, error in
            if let error { fatalError("Store load failed: \(error)") }
        }
        context = container.viewContext
        
        repository = LocationRepository(context: context)
        
        // 테스트 데이터: Case, Suspect 생성 (필수 필드 포함)
        caseId = UUID()
        let caseEntity = CaseEntity(context: context)
        caseEntity.id = caseId
        caseEntity.name = "테스트"
        caseEntity.number = "TEST-001" // 필수 필드
        caseEntity.crime = "테스트 범죄" // 필수 필드
        
        suspect = SuspectEntity(context: context)
        suspect.id = UUID()
        suspect.name = "" // 빈 문자열
        suspect.relateCase = caseEntity
        caseEntity.addToSuspects(suspect)
        
        try context.save()
    }

    // TODO: locationEntity 컬러타입 추가했는데 테스트 코드는 수정이 안되서 에러가 발생함 - 추후 추가할 것
//    func testFetchLocations() async throws {
//        // Given: Location 생성
//        let location = Location(
//            id: UUID(),
//            address: "테스트 주소",
//            title: nil,
//            note: nil,
//            pointLatitude: 36.0,
//            pointLongitude: 129.0,
//            boxMinLatitude: nil,
//            boxMinLongitude: nil,
//            boxMaxLatitude: nil,
//            boxMaxLongitude: nil,
//            locationType: 2,
//            receivedAt: nil
//        )
//        try await repository.createLocations(data: [location], caseId: caseId)
//
//        // When: 조회
//        let locations = try await repository.fetchLocations(caseId: caseId)
//
//        // Then
//        XCTAssertEqual(locations.count, 1)
//        XCTAssertEqual(locations.first?.id, location.id)
//    }
    
//    func testCreateLocation() async throws {
//        // Given
//        let location = Location(
//            id: UUID(),
//            address: "생성 테스트",
//            title: nil,
//            note: nil,
//            pointLatitude: 37.0,
//            pointLongitude: 130.0,
//            boxMinLatitude: nil,
//            boxMinLongitude: nil,
//            boxMaxLatitude: nil,
//            boxMaxLongitude: nil,
//            locationType: 1,
//            receivedAt: nil
//        )
//
//        // When
//        try await repository.createLocations(data: [location], caseId: caseId)
//
//        // Then
//        let locations = try await repository.fetchLocations(caseId: caseId)
//        XCTAssertEqual(locations.count, 1)
//    }
    
//    func testDeleteLocation() async throws {
//        // Given
//        let location = Location(
//            id: UUID(),
//            address: "삭제 테스트",
//            title: nil,
//            note: nil,
//            pointLatitude: 38.0,
//            pointLongitude: 131.0,
//            boxMinLatitude: nil,
//            boxMinLongitude: nil,
//            boxMaxLatitude: nil,
//            boxMaxLongitude: nil,
//            locationType: 0,
//            receivedAt: nil
//        )
//        try await repository.createLocations(data: [location], caseId: caseId)
        
//        // When
//        try await repository.deleteLocation(id: location.id)
//
//        // Then
//        let locations = try await repository.fetchLocations(caseId: caseId)
//        XCTAssertEqual(locations.count, 0)
//    }
}
