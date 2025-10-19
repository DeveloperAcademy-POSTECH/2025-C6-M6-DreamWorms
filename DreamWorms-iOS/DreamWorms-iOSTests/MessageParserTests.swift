//
//  MessageParserTests.swift
//  DreamWorms-iOSTests
//
//  Created by Moo on 10/18/25.
//

@testable import DreamWorms_iOS
import XCTest

final class MessageParserTests: XCTestCase {
    func testExtractAddress() {
        XCTAssertEqual(MessageParser.extractAddress(from: MockMessage.validAddressMessage), "부산강서구지사동")
        XCTAssertEqual(MessageParser.extractAddress(from: MockMessage.validAddressWithNumber), "서울특별시 강남구 역삼1동")
        XCTAssertEqual(MessageParser.extractAddress(from: MockMessage.powerOffMessage), nil)
    }
    
    func testContainsInvalidKeywords() {
        // 정상 메시지 (키워드 없음)
        XCTAssertFalse(MessageParser.containsInvalidKeywords(from: MockMessage.validAddressMessage))
        XCTAssertFalse(MessageParser.containsInvalidKeywords(from: MockMessage.validAddressWithNumber))
        
        // 전원 꺼진 메시지 (키워드 있음)
        XCTAssertTrue(MessageParser.containsInvalidKeywords(from: MockMessage.powerOffMessage))
        
        // 개별 패턴 테스트
        XCTAssertTrue(MessageParser.containsInvalidKeywords(from: "확인불가"))
        XCTAssertTrue(MessageParser.containsInvalidKeywords(from: "확인 불가"))
        XCTAssertTrue(MessageParser.containsInvalidKeywords(from: "MSC 정보 확인 불가"))
        
        // 매칭 안 되는 케이스
        XCTAssertFalse(MessageParser.containsInvalidKeywords(from: "부산강서구"))
    }
        
    func testFindAddress() {
        let pattern = "^(?=.*[가-힣])[가-힣0-9\\s]+$"
        
        // 1. 한글 포함 (유효)
        XCTAssertEqual(MessageParser.findAddress(from: MockMessage.validAddressMessage, pattern: pattern), "부산강서구지사동")
        XCTAssertEqual(MessageParser.findAddress(from: MockMessage.validAddressWithNumber, pattern: pattern), "서울특별시 강남구 역삼1동")

        // 한글 없음
        XCTAssertNil(MessageParser.findAddress(from: "123456", pattern: pattern))

        // 특수문자, 영어 포함
        XCTAssertNil(MessageParser.findAddress(from: "[Web발신]", pattern: pattern))
    }
}
