//
//  SUSA24Tests.swift
//  SUSA24Tests
//
//  Created by mini on 10/29/25.
//

import XCTest
@testable import SUSA24_iOS

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
}
