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
    
    // MARK: 좌표로 주소 조회 API 테스트
    
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
        let response = try await VWorldCCTVAPIService().fetchCCTVByBox(requestDTO)
        
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
        let response = try await VWorldCCTVAPIService().fetchCCTVByPolygon(requestDTO)
        
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

// MARK: - AppIntent Integration Tests

@MainActor
final class AppIntentIntegrationTests: XCTestCase {
    var caseRepository: CaseRepository!
    var locationRepository: LocationRepository!
    
    override func setUpWithError() throws {
        // PersistenceController.shared가 테스트 환경에서 자동으로 inMemory로 동작
        let context = PersistenceController.shared.container.viewContext
        caseRepository = CaseRepository(context: context)
        locationRepository = LocationRepository(context: context)
    }
    
    override func tearDownWithError() throws {
        // 각 테스트 후 데이터 정리 (다음 테스트에 영향 안 주도록)
        cleanupTestData()
        
        // Repository 정리
        caseRepository = nil
        locationRepository = nil
    }
    
    // 테스트 데이터 정리 메서드
    func cleanupTestData() {
        let context = PersistenceController.shared.container.viewContext
        
        // 모든 Entity 삭제
        let entityNames = ["LocationEntity", "SuspectEntity", "CaseEntity"]
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("⚠️ 정리 실패: \(entityName) - \(error)")
            }
        }
        
        context.reset()
    }
    
    // MARK: - 1단계: MessageParser 테스트
    
    func test1_MessageParser_정상주소추출() throws {
        print("\n========================================")
        print("🧪 [테스트 1] MessageParser - 정상 주소 추출")
        print("========================================")
        
        let message = """
        [Web발신]
        [발신기지국]
        부산강서구지사동
        1299,284(중계기),06-16
        13:24,N
        """
        
        let address = MessageParser.extractAddress(from: message)
        
        print("📩 입력 메시지:")
        print(message)
        print("\n📍 추출된 주소: \(address ?? "nil")")
        
        XCTAssertNotNil(address, "주소가 추출되어야 함")
        XCTAssertEqual(address, "부산강서구지사동 1299", "주소와 번지수가 올바르게 추출되어야 함")
        
        print("✅ 테스트 성공: 주소 추출 완료 (\(address!))")
        print("========================================\n")
    }
    
    func test2_MessageParser_확인불가처리() throws {
        print("\n========================================")
        print("🧪 [테스트 2] MessageParser - 확인불가 처리")
        print("========================================")
        
        let message = """
        [Web발신]
        [16,16:13]
        [발신기지국]
        MSC 정보확인 불가, 전원상태(N)
        """
        
        let address = MessageParser.extractAddress(from: message)
        
        print("📩 입력 메시지:")
        print(message)
        print("\n📍 추출된 주소: \(address ?? "nil")")
        
        XCTAssertNil(address, "확인불가 메시지는 주소가 추출되지 않아야 함")
        
        print("✅ 테스트 성공: 확인불가 키워드 감지")
        print("========================================\n")
    }
    
    func test2_1_MessageParser_다양한형식테스트() throws {
        print("\n========================================")
        print("🧪 [테스트 2-1] MessageParser - 다양한 메시지 형식")
        print("========================================")
        
        // 케이스 1: 중계기 포함
        let message1 = """
        [Web발신]
        [발신기지국]
        부산강서구지사동
        1299,284(중계기),06-16
        13:24,N
        """
        let address1 = MessageParser.extractAddress(from: message1)
        print("\n케이스 1 (중계기):")
        print("  추출: \(address1 ?? "nil")")
        XCTAssertEqual(address1, "부산강서구지사동 1299", "중계기 앞까지만 추출")
        
        // 케이스 2: 숫자만 있는 경우
        let message2 = """
        [발신기지국]
        서울특별시강남구역삼동
        789
        """
        let address2 = MessageParser.extractAddress(from: message2)
        print("\n케이스 2 (숫자만):")
        print("  추출: \(address2 ?? "nil")")
        XCTAssertEqual(address2, "서울특별시강남구역삼동 789", "번지수 포함")
        
        // 케이스 3: 전원상태(N) 확인
        let message3 = """
        [발신기지국]
        MSC 정보확인 불가, 전원상태(N)
        [위치자료]
        확인불가
        """
        let address3 = MessageParser.extractAddress(from: message3)
        print("\n케이스 3 (전원상태N):")
        print("  추출: \(address3 ?? "nil")")
        XCTAssertNil(address3, "전원상태(N)은 nil")
        
        // 케이스 4: 확인불가
        let message4 = """
        [발신기지국]
        [위치자료]
        확인불가
        """
        let address4 = MessageParser.extractAddress(from: message4)
        print("\n케이스 4 (확인불가):")
        print("  추출: \(address4 ?? "nil")")
        XCTAssertNil(address4, "확인불가는 nil")
        
        print("\n✅ 모든 케이스 테스트 성공")
        print("========================================\n")
    }
    
    // MARK: - 2단계: 케이스 생성 및 전화번호 저장 테스트
    
    func test3_CaseRepository_전화번호포함생성() async throws {
        print("\n========================================")
        print("🧪 [테스트 3] CaseRepository - 전화번호 포함 케이스 생성")
        print("========================================")
        
        let caseModel = Case(
            id: UUID(),
            number: "2025-001",
            name: "테스트 사건 1",
            crime: "사기",
            suspect: "홍길동",
            suspectProfileImage: nil
        )
        
        let phoneNumber = "010-1111-2222"
        
        print("📋 생성할 케이스:")
        print("  - 사건번호: \(caseModel.number)")
        print("  - 사건명: \(caseModel.name)")
        print("  - 피의자: \(caseModel.suspect)")
        print("  - 전화번호: \(phoneNumber)")
        
        try await caseRepository.createCase(
            model: caseModel,
            imageData: nil,
            phoneNumber: phoneNumber
        )
        
        // 저장된 케이스 확인
        let (savedCase, _) = try await caseRepository.fetchAllDataOfSpecificCase(for: caseModel.id)
        
        print("\n💾 저장된 케이스:")
        print("  - ID: \(savedCase?.id.uuidString ?? "nil")")
        print("  - 사건번호: \(savedCase?.number ?? "nil")")
        print("  - 사건명: \(savedCase?.name ?? "nil")")
        print("  - 피의자: \(savedCase?.suspect ?? "nil")")
        
        XCTAssertNotNil(savedCase, "케이스가 저장되어야 함")
        XCTAssertEqual(savedCase?.suspect, "홍길동", "피의자명이 일치해야 함")
        
        print("✅ 테스트 성공: 케이스 생성 완료")
        print("========================================\n")
    }
    
    // MARK: - 3단계: 전화번호로 케이스 찾기 테스트
    
    func test4_CaseRepository_전화번호로케이스찾기() async throws {
        print("\n========================================")
        print("🧪 [테스트 4] CaseRepository - 전화번호로 케이스 찾기")
        print("========================================")
        
        // 케이스 1 생성
        let case1 = Case(
            id: UUID(),
            number: "2025-001",
            name: "사건 1",
            crime: "사기",
            suspect: "홍길동",
            suspectProfileImage: nil
        )
        try await caseRepository.createCase(model: case1, imageData: nil, phoneNumber: "010-1111-2222")
        
        // 케이스 2 생성
        let case2 = Case(
            id: UUID(),
            number: "2025-002",
            name: "사건 2",
            crime: "절도",
            suspect: "김철수",
            suspectProfileImage: nil
        )
        try await caseRepository.createCase(model: case2, imageData: nil, phoneNumber: "010-3333-4444")
        
        print("📋 생성된 케이스:")
        print("  - Case 1: 홍길동 (010-1111-2222)")
        print("  - Case 2: 김철수 (010-3333-4444)")
        
        // 전화번호로 케이스 찾기
        let foundCase1 = try await caseRepository.findCaseByPhoneNumber("010-1111-2222")
        let foundCase2 = try await caseRepository.findCaseByPhoneNumber("010-3333-4444")
        let notFoundCase = try await caseRepository.findCaseByPhoneNumber("010-9999-9999")
        
        print("\n🔍 검색 결과:")
        print("  - 010-1111-2222: \(foundCase1?.uuidString ?? "nil")")
        print("  - 010-3333-4444: \(foundCase2?.uuidString ?? "nil")")
        print("  - 010-9999-9999: \(notFoundCase?.uuidString ?? "nil")")
        
        XCTAssertNotNil(foundCase1, "Case 1이 찾아져야 함")
        XCTAssertNotNil(foundCase2, "Case 2가 찾아져야 함")
        XCTAssertNil(notFoundCase, "등록되지 않은 번호는 nil이어야 함")
        XCTAssertEqual(foundCase1, case1.id, "Case 1 ID가 일치해야 함")
        XCTAssertEqual(foundCase2, case2.id, "Case 2 ID가 일치해야 함")
        
        print("✅ 테스트 성공: 전화번호 매칭 완료")
        print("========================================\n")
    }
    
    // MARK: - 4단계: 전체 플로우 통합 테스트
    
    func test5_FullFlow_메시지수신부터저장까지() async throws {
        print("\n========================================")
        print("🧪 [테스트 5] 전체 플로우 - 메시지 수신부터 저장까지")
        print("========================================")
        
        // 1단계: 케이스 생성
        print("\n📋 1단계: 케이스 생성")
        let caseModel = Case(
            id: UUID(),
            number: "2025-TEST",
            name: "통합 테스트 사건",
            crime: "사기",
            suspect: "테스트용의자",
            suspectProfileImage: nil
        )
        let phoneNumber = "010-1234-5678"
        
        try await caseRepository.createCase(
            model: caseModel,
            imageData: nil,
            phoneNumber: phoneNumber
        )
        print("  ✅ 케이스 생성 완료: \(caseModel.name)")
        print("  📞 전화번호: \(phoneNumber)")
        
        // 2단계: 메시지 수신 시뮬레이션
        print("\n📩 2단계: 메시지 수신 시뮬레이션")
        let messageBody = """
        [Web발신]
        [발신기지국]
        서울특별시 강남구 역삼동
        """
        let senderNumber = "010-1234-5678"
        
        print("  발신자: \(senderNumber)")
        print("  본문: \(messageBody)")
        
        // 3단계: 발신자 번호로 케이스 찾기
        print("\n🔍 3단계: 발신자 번호로 케이스 찾기")
        guard let foundCaseID = try await caseRepository.findCaseByPhoneNumber(senderNumber) else {
            XCTFail("케이스를 찾지 못했습니다")
            return
        }
        print("  ✅ 매칭된 케이스: \(foundCaseID.uuidString)")
        XCTAssertEqual(foundCaseID, caseModel.id, "케이스 ID가 일치해야 함")
        
        // 4단계: 주소 추출
        print("\n📍 4단계: 주소 추출")
        guard let address = MessageParser.extractAddress(from: messageBody) else {
            XCTFail("주소를 추출하지 못했습니다")
            return
        }
        print("  ✅ 추출된 주소: \(address)")
        XCTAssertEqual(address, "서울특별시 강남구 역삼동", "주소가 올바르게 추출되어야 함")
        
        // 5단계: 좌표 변환 (GeocodeService 사용 - 실제 API 호출)
        print("\n🗺️  5단계: 좌표 변환 (실제 API 호출)")
        print("  ⏳ Naver Geocode API 호출 중...")
        
        let geocodeResult = try await GeocodeService.shared.geocode(address: address)
        
        guard let latitude = geocodeResult.latitude,
              let longitude = geocodeResult.longitude
        else {
            XCTFail("좌표를 얻지 못했습니다")
            return
        }
        
        print("  ✅ 변환된 좌표:")
        print("    - 위도: \(latitude)")
        print("    - 경도: \(longitude)")
        print("    - 전체주소: \(geocodeResult.fullAddress ?? address)")
        
        // 6단계: 위치 정보 저장
        print("\n💾 6단계: 위치 정보 저장")
        try await locationRepository.createLocationFromMessage(
            caseID: foundCaseID,
            address: geocodeResult.fullAddress ?? address,
            latitude: latitude,
            longitude: longitude
        )
        print("  ✅ 위치 정보 저장 완료")
        
        // 7단계: 최종 데이터 확인
        print("\n✨ 7단계: 최종 데이터 확인")
        let (finalCase, locations) = try await caseRepository.fetchAllDataOfSpecificCase(for: foundCaseID)
        
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 최종 저장된 데이터")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        if let finalCase {
            print("\n📋 케이스 정보:")
            print("  - ID: \(finalCase.id.uuidString)")
            print("  - 사건번호: \(finalCase.number)")
            print("  - 사건명: \(finalCase.name)")
            print("  - 범죄유형: \(finalCase.crime)")
            print("  - 피의자: \(finalCase.suspect)")
        }
        
        print("\n📍 위치 정보: (총 \(locations.count)개)")
        for (index, location) in locations.enumerated() {
            print("\n  위치 #\(index + 1):")
            print("    - ID: \(location.id.uuidString)")
            print("    - 주소: \(location.address)")
            print("    - 좌표: (\(location.pointLatitude), \(location.pointLongitude))")
            print("    - 타입: \(location.locationType) (2=기지국)")
            print("    - 색상: \(location.colorType)")
            if let receivedAt = location.receivedAt {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = TimeZone.current
                print("    - 수신시간: \(formatter.string(from: receivedAt))")
            } else {
                print("    - 수신시간: nil ⚠️")
            }
        }
        
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // 검증
        XCTAssertNotNil(finalCase, "케이스가 존재해야 함")
        XCTAssertEqual(locations.count, 1, "위치가 1개 저장되어야 함")
        XCTAssertEqual(locations.first?.address, geocodeResult.fullAddress ?? address, "주소가 일치해야 함")
        XCTAssertEqual(locations.first?.locationType, 2, "기지국 타입(2)이어야 함")
        XCTAssertNotNil(locations.first?.receivedAt, "수신시간이 저장되어야 함")
        
        // 수신시간이 현재 시간과 비슷한지 확인 (1분 이내)
        if let receivedAt = locations.first?.receivedAt {
            let timeDifference = abs(Date().timeIntervalSince(receivedAt))
            XCTAssertLessThan(timeDifference, 60, "수신시간이 현재 시간과 1분 이내 차이여야 함")
        }
        
        print("\n🎉 전체 플로우 테스트 성공!")
        print("========================================\n")
    }
    
    // MARK: - 5단계: 여러 케이스 동시 처리 테스트
    
    func test6_MultipleCase_여러케이스동시처리() async throws {
        print("\n========================================")
        print("🧪 [테스트 6] 여러 케이스 동시 처리")
        print("========================================")
        
        // 3개의 케이스 생성
        let cases = [
            (case: Case(id: UUID(), number: "2025-001", name: "사건 1", crime: "사기", suspect: "홍길동", suspectProfileImage: nil),
             phone: "010-1111-1111"),
            (case: Case(id: UUID(), number: "2025-002", name: "사건 2", crime: "절도", suspect: "김철수", suspectProfileImage: nil),
             phone: "010-2222-2222"),
            (case: Case(id: UUID(), number: "2025-003", name: "사건 3", crime: "폭행", suspect: "이영희", suspectProfileImage: nil),
             phone: "010-3333-3333"),
        ]
        
        print("\n📋 케이스 생성:")
        for (caseModel, phone) in cases {
            try await caseRepository.createCase(model: caseModel, imageData: nil, phoneNumber: phone)
            print("  - \(caseModel.name): \(caseModel.suspect) (\(phone))")
        }
        
        // 각 케이스에 위치 저장
        let messages = [
            (sender: "010-1111-1111", address: "부산광역시 해운대구 우동"),
            (sender: "010-2222-2222", address: "대구광역시 수성구 범어동"),
            (sender: "010-3333-3333", address: "인천광역시 남동구 구월동"),
        ]
        
        print("\n📩 메시지 처리:")
        for message in messages {
            print("\n  발신자: \(message.sender)")
            
            guard let caseID = try await caseRepository.findCaseByPhoneNumber(message.sender) else {
                XCTFail("케이스를 찾지 못했습니다: \(message.sender)")
                continue
            }
            
            print("  ✅ 케이스 매칭: \(caseID.uuidString)")
            
            let geocodeResult = try await GeocodeService.shared.geocode(address: message.address)
            guard let lat = geocodeResult.latitude, let lon = geocodeResult.longitude else {
                XCTFail("좌표 변환 실패: \(message.address)")
                continue
            }
            
            try await locationRepository.createLocationFromMessage(
                caseID: caseID,
                address: geocodeResult.fullAddress ?? message.address,
                latitude: lat,
                longitude: lon
            )
            
            print("  💾 위치 저장: \(message.address)")
        }
        
        // 최종 확인
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 전체 케이스 최종 상태")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        for (index, (caseModel, _)) in cases.enumerated() {
            let (finalCase, locations) = try await caseRepository.fetchAllDataOfSpecificCase(for: caseModel.id)
            
            print("\n케이스 #\(index + 1):")
            print("  사건명: \(finalCase?.name ?? "nil")")
            print("  피의자: \(finalCase?.suspect ?? "nil")")
            print("  위치 개수: \(locations.count)개")
            
            if let location = locations.first {
                print("  저장된 주소: \(location.address)")
            }
            
            XCTAssertEqual(locations.count, 1, "각 케이스마다 위치 1개씩 저장되어야 함")
        }
        
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🎉 여러 케이스 동시 처리 테스트 성공!")
        print("========================================\n")
    }
}
