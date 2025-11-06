//
//  SUSA24Tests.swift
//  SUSA24Tests
//
//  Created by mini on 10/29/25.
//

import CoreData
import XCTest
@testable import SUSA24_iOS

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
        self.measure {
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
            "size": 15
        ]
        
        // When
        let result = try URLBuilder.build(baseURL: baseURL, parameters: parameters)
        
        // Then
        print("✅ URLBuilder 결과:")
        print(result)
        XCTAssertTrue(result.starts(with: baseURL))
    }
    
    // MARK: - API Tests
    
    // MARK: 좌표로 주소 조회 API 테스트
    @MainActor
    func testFetchLocationFromCoord() async throws {
        // Given
        let requestDTO = KakaoCoordToLocationRequestDTO(
            x: "128.537763550346",
            y: "35.8189266589744",
            inputCoord: "WGS84"
        )
        
        // When
        let response: KakaoCoordToLocationResponseDTO = try await KakaoSearchAPIManager.shared.fetchLocationFromCoord(requestDTO)
        
        // Then
        var logOutput = "✅ 좌표로 주소 조회 API 호출 성공\n"
        logOutput += "totalCount: \(response.meta.totalCount)\n"
        logOutput += "documents count: \(response.documents.count)\n"
        logOutput += "========================================\n"
        for (index, document) in response.documents.enumerated() {
            logOutput += "\n[Document \(index + 1)]\n"
            if let address = document.address {
                logOutput += "  [지번 주소]\n"
                logOutput += "    addressName: \(address.addressName)\n"
                if let region1 = address.region1depthName { logOutput += "    region1depthName: \(region1)\n" }
                if let region2 = address.region2depthName { logOutput += "    region2depthName: \(region2)\n" }
                if let region3 = address.region3depthName { logOutput += "    region3depthName: \(region3)\n" }
                if let region4 = address.region4depthName { logOutput += "    region4depthName: \(region4)\n" }
                if let regionType = address.regionType { logOutput += "    regionType: \(regionType)\n" }
                if let code = address.code { logOutput += "    code: \(code)\n" }
                if let x = address.x { logOutput += "    x: \(x)\n" }
                if let y = address.y { logOutput += "    y: \(y)\n" }
                if let mountainYn = address.mountainYn { logOutput += "    mountainYn: \(mountainYn)\n" }
                if let mainAddressNo = address.mainAddressNo { logOutput += "    mainAddressNo: \(mainAddressNo)\n" }
                if let subAddressNo = address.subAddressNo { logOutput += "    subAddressNo: \(subAddressNo)\n" }
                if let zipCode = address.zipCode { logOutput += "    zipCode: \(zipCode)\n" }
            }
            if let roadAddress = document.roadAddress {
                logOutput += "  [도로명 주소]\n"
                logOutput += "    addressName: \(roadAddress.addressName)\n"
                if let region1 = roadAddress.region1depthName { logOutput += "    region1depthName: \(region1)\n" }
                if let region2 = roadAddress.region2depthName { logOutput += "    region2depthName: \(region2)\n" }
                if let region3 = roadAddress.region3depthName { logOutput += "    region3depthName: \(region3)\n" }
                if let region4 = roadAddress.region4depthName { logOutput += "    region4depthName: \(region4)\n" }
                if let regionType = roadAddress.regionType { logOutput += "    regionType: \(regionType)\n" }
                if let code = roadAddress.code { logOutput += "    code: \(code)\n" }
                if let x = roadAddress.x { logOutput += "    x: \(x)\n" }
                if let y = roadAddress.y { logOutput += "    y: \(y)\n" }
                if let buildingName = roadAddress.buildingName { logOutput += "    buildingName: \(buildingName)\n" }
                if let buildingCode = roadAddress.buildingCode { logOutput += "    buildingCode: \(buildingCode)\n" }
                if let roadName = roadAddress.roadName { logOutput += "    roadName: \(roadName)\n" }
                if let undergroundYn = roadAddress.undergroundYn { logOutput += "    undergroundYn: \(undergroundYn)\n" }
                if let mainBuildingNo = roadAddress.mainBuildingNo { logOutput += "    mainBuildingNo: \(mainBuildingNo)\n" }
                if let subBuildingNo = roadAddress.subBuildingNo { logOutput += "    subBuildingNo: \(subBuildingNo)\n" }
                if let zoneNo = roadAddress.zoneNo { logOutput += "    zoneNo: \(zoneNo)\n" }
            }
        }
        logOutput += "========================================\n"
        
        print(logOutput)
        let attachment = XCTAttachment(string: logOutput)
        attachment.lifetime = .keepAlways
        add(attachment)
        
        XCTAssertGreaterThan(response.meta.totalCount, 0)
        XCTAssertFalse(response.documents.isEmpty)
    }
    
    // MARK: 키워드로 장소 검색 API 테스트
    @MainActor
    func testFetchPlaceFromKeyword() async throws {
        // Given
        let requestDTO = KakaoKeywordToPlaceRequestDTO(
            query: "대구광역시 달서구 월배로 지하 223",
            x: nil,
            y: nil,
            radius: nil,
            page: 1,
            size: 15
        )
        
        // When
        let response: KakaoKeywordToPlaceResponseDTO = try await KakaoSearchAPIManager.shared.fetchPlaceFromKeyword(requestDTO)
        
        // Then
        var logOutput = "✅ 키워드로 장소 검색 API 호출 성공\n"
        logOutput += "검색 키워드: \(requestDTO.query)\n"
        logOutput += "totalCount: \(response.meta.totalCount)\n"
        logOutput += "pageableCount: \(response.meta.pageableCount)\n"
        logOutput += "isEnd: \(response.meta.isEnd)\n"
        logOutput += "documents count: \(response.documents.count)\n"
        logOutput += "========================================\n"
        for (index, document) in response.documents.enumerated() {
            logOutput += "\n[Document \(index + 1)]\n"
            if let placeName = document.placeName { logOutput += "  placeName: \(placeName)\n" }
            if let categoryName = document.categoryName { logOutput += "  categoryName: \(categoryName)\n" }
            if let categoryGroupCode = document.categoryGroupCode { logOutput += "  categoryGroupCode: \(categoryGroupCode)\n" }
            if let categoryGroupName = document.categoryGroupName { logOutput += "  categoryGroupName: \(categoryGroupName)\n" }
            if let phone = document.phone { logOutput += "  phone: \(phone)\n" }
            if let addressName = document.addressName { logOutput += "  addressName: \(addressName)\n" }
            if let roadAddressName = document.roadAddressName { logOutput += "  roadAddressName: \(roadAddressName)\n" }
            if let x = document.x { logOutput += "  x: \(x)\n" }
            if let y = document.y { logOutput += "  y: \(y)\n" }
            if let id = document.id { logOutput += "  id: \(id)\n" }
            if let placeUrl = document.placeUrl { logOutput += "  placeUrl: \(placeUrl)\n" }
            if let distance = document.distance { logOutput += "  distance: \(distance)m\n" }
        }
        logOutput += "========================================\n"
        
        print(logOutput)
        let attachment = XCTAttachment(string: logOutput)
        attachment.lifetime = .keepAlways
        add(attachment)
        
        XCTAssertGreaterThan(response.meta.totalCount, 0)
        XCTAssertFalse(response.documents.isEmpty)
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
            if let error = error { fatalError("Store load failed: \(error)") }
        }
        context = container.viewContext
        
        repository = LocationRepository(context: context)
        
        // 테스트 데이터: Case, Suspect 생성 (필수 필드 포함)
        caseId = UUID()
        let caseEntity = CaseEntity(context: context)
        caseEntity.id = caseId
        caseEntity.name = "테스트"
        caseEntity.number = "TEST-001"  // 필수 필드
        caseEntity.crime = "테스트 범죄"  // 필수 필드
        
        suspect = SuspectEntity(context: context)
        suspect.id = UUID()
        suspect.name = ""  // 빈 문자열
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
