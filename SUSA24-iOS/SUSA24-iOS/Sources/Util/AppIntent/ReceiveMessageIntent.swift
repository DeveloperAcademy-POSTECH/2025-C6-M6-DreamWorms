//
//  ReceiveMessageIntent.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/10/25.
//

import AppIntents
import CoreData
import Foundation

/// 기지국에서 보낸 문자 메시지를 받아 위치 정보를 자동으로 저장하는 AppIntent
struct ReceiveMessageIntent: AppIntent {
    static let title: LocalizedStringResource = "기지국 위치정보 저장하기"
    static let description = IntentDescription("전달된 문자 메시지에 포함된 주소를 추출하여 케이스에 저장합니다.")
    
    @Parameter(title: "메시지 본문")
    var messageBody: String
    
    @Parameter(title: "발신자 번호")
    var senderNumber: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("본문: \(\.$messageBody)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        
        // Repository 생성
        let context = PersistenceController.shared.container.viewContext
        let caseRepository = CaseRepository(context: context)
        let locationRepository = LocationRepository(context: context)
        
        // 1. 발신자 번호 확인
        guard let senderNumber else {
            print(" X [AppIntent] 발신자 번호가 없습니다.")
            print("========================================\n")
            return .result()
        }
        
        print("발신자: \(senderNumber)")
        
        // 2. 발신자 번호로 케이스 찾기
        guard let caseID = try await caseRepository.findCaseByPhoneNumber(senderNumber) else {
            print(" X [AppIntent] 등록되지 않은 발신자입니다.")
            print("========================================\n")
            return .result()
        }
        
        print(" 매칭된 케이스: \(caseID)")
        
        // 3. 주소 추출
        guard let address = MessageParser.extractAddress(from: messageBody) else {
            print(" 주소를 추출할 수 없습니다.")
            print("   본문: \(messageBody)")
            print("========================================\n")
            return .result()
        }
        
        print(" 추출된 주소: \(address)")
        
        // 4. 좌표 변환 및 저장
        do {
            let geocodeResult = try await GeocodeService.shared.geocode(address: address)
            
            guard let latitude = geocodeResult.latitude,
                  let longitude = geocodeResult.longitude
            else {
                print(" 좌표 변환 실패")
                print("========================================\n")
                return .result()
            }
            
            print("🗺️  좌표: (\(latitude), \(longitude))")
            
            // Repository를 통한 저장
            try await locationRepository.createLocationFromMessage(
                caseID: caseID,
                address: geocodeResult.fullAddress,
                latitude: latitude,
                longitude: longitude
            )
            
            print(" 위치 정보 저장 완료")
            print("========================================\n")
            
        } catch {
            print(" 오류 발생: \(error)")
            print("========================================\n")
        }
        
        return .result()
    }
}
