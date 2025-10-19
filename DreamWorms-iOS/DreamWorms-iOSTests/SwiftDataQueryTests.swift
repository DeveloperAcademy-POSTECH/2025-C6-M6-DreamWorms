//
//  SwiftDataQueryTests.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/18/25.
//

@testable import DreamWorms_iOS
import os
import SwiftData
import XCTest

final class SwiftDataQueryTests: XCTestCase {
    private let logger = Logger(subsystem: "com.dreamworms.tests", category: "SwiftData")
    
    /// 현재 저장된 모든 CaseLocation을 조회합니다.
    func testFetchAllCaseLocations() throws {
        let container = try ModelContainer(
            for: DreamWorms_iOS.Case.self,
            CaseLocation.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        let context = ModelContext(container)
        
        // 모든 CaseLocation 조회
        let descriptor = FetchDescriptor<CaseLocation>()
        let locations = try context.fetch(descriptor)
        
        var output = ""
        
        for (index, location) in locations.enumerated() {
            output += """
            
            [\(index + 1)] Location
              ID: \(location.id.uuidString)
              수신 시간: \(location.receivedAt.description)
              타입: \(location.pinType.rawValue)
              주소: \(location.address ?? "N/A")
              위도: \(location.latitude?.description ?? "N/A")
              경도: \(location.longitude?.description ?? "N/A")
                
            """
            
            if let parentCase = location.parentCase {
                output += "  소속 Case: \(parentCase.name)\n"
            } else {
                output += "  소속 Case: 없음 (미할당)\n"
            }
        }
        
        let attachment = XCTAttachment(string: output)
        attachment.name = "저장된 CaseLocation 목록"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        print(output)
        
        XCTAssertNotNil(locations)
    }
}
