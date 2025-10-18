//
//  ReceiveMessageIntent.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/18/25.
//

import AppIntents
import Foundation
import SwiftData

struct ReceiveMessageIntent: AppIntent {
    static let title: LocalizedStringResource = "기지국 위치정보 저장하기"
    static let description = IntentDescription("전달된 문자 메시지에 포함된 주소를 저장합니다.")
    
    @Parameter(title: "메시지 본문")
    var bodyText: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("본문: \(\.$bodyText)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: DreamWorms_iOS.Case.self, CaseLocation.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        let modelContext = ModelContext(container)
        
        // NOTE: 삭제 예정
        let activeCase = try fetchActiveCase(from: modelContext)
        
        guard let address = MessageParser.extractAddress(from: bodyText) else {
            let location = CaseLocation(pinType: .telecom)
            location.parentCase = activeCase
            modelContext.insert(location)
            try modelContext.save()
            return .result()
        }
        
        do {
            let geocodeResult = try await GeocodeService.geocode(address: address)
            
            guard let latitude = geocodeResult.latitude,
                  let longitude = geocodeResult.longitude
            else {
                let location = CaseLocation(pinType: .telecom)
                location.parentCase = activeCase
                modelContext.insert(location)
                try modelContext.save()
                return .result()
            }
            
            let location = CaseLocation(
                pinType: .telecom,
                address: geocodeResult.fullAddress,
                latitude: latitude,
                longitude: longitude
            )
            location.parentCase = activeCase
            modelContext.insert(location)
            try modelContext.save()
            
        } catch {
            let location = CaseLocation(pinType: .telecom)
            location.parentCase = activeCase
            modelContext.insert(location)
            try modelContext.save()
        }
        
        return .result()
    }
    
    // NOTE: 임시 방편 코드(추후제거)
    @MainActor
    private func fetchActiveCase(from context: ModelContext) throws -> DreamWorms_iOS.Case? {
        guard let idString = UserDefaults.standard.string(forKey: "activeCase"),
              let activeCaseID = UUID(uuidString: idString)
        else {
            return nil
        }
        
        let descriptor = FetchDescriptor<DreamWorms_iOS.Case>(
            predicate: #Predicate { $0.id == activeCaseID }
        )
        
        return try context.fetch(descriptor).first
    }
}
