//
//  ReceiveMessageIntentTests.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/18/25.
//

@testable import DreamWorms_iOS
import XCTest

final class ReceiveMessageIntentTests: XCTestCase {
    func testReceiveMessageWithValidAddress() async throws {
        let intent = ReceiveMessageIntent()
        intent.bodyText = MockMessage.validAddressMessage
        
        let result = try await intent.perform()
        
        XCTAssertNotNil(result)
    }
    
    func testReceiveMessageWithPowerOff() async throws {
        let intent = ReceiveMessageIntent()
        intent.bodyText = MockMessage.powerOffMessage
        
        let result = try await intent.perform()

        XCTAssertNotNil(result)
    }
}
