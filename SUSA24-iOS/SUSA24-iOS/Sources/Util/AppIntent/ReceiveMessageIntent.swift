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
    
    @Parameter(title: "피의자 추적 전화번호")
    var senderPhoneNumber: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("본문: \(\.$messageBody), 피의자 추적 전화번호: \(\.$senderPhoneNumber)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 기지국 위치정보 저장 시작.

        // Repository 생성
        let context = PersistenceController.shared.container.viewContext
        let caseRepository = CaseRepository(context: context)
        let locationRepository = LocationRepository(context: context)
            
        // 1. 정규화 시키기
        let normalizePhoneNumber = senderPhoneNumber
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+82", with: "0")

        // 2. 전화번호로 케이스 찾기
        guard let caseID = try await caseRepository.findCaseTest(byCasePhoneNumber: normalizePhoneNumber) else {
            // 찾을 수 없는 전화번호 예외처리
            return .result(dialog: "등록되지 않은 전화번호입니다.")
        }

        print("***** 매칭된 케이스 ID: \(caseID)")

        // 3. 주소 추출
        guard let address = MessageParser.extractAddress(from: messageBody) else {
            // 주소 추출 불가 예외처리
            return .result(dialog: "문자에서 주소를 추출할 수 없습니다.")
        }

        print(" *** 추출된 주소: \(address)")

        // 4. 좌표 변환 및 저장
        do {
            let geocodeResult = try await NaverGeocodeAPIService.shared.geocode(address: address)

            guard let latitude = geocodeResult.latitude,
                  let longitude = geocodeResult.longitude
            else {
                // 좌표 전환 실패 예외처리
                return .result(dialog: "좌표 변환 실패")
            }

            print("***  좌표: (\(latitude), \(longitude))")

            // Repository를 통한 저장
            try await locationRepository.createLocationFromMessage(
                caseID: caseID,
                address: geocodeResult.fullAddress,
                latitude: latitude,
                longitude: longitude
            )

            // 위치 저장 완료
            return .result(dialog: "위치 저장 완료.")

        } catch {
            // App Intent 위치 저장 실패
            return .result(dialog: "위치 저장 실패")
        }
    }
}
