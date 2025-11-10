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
        
        
        return .result()
    }
}
