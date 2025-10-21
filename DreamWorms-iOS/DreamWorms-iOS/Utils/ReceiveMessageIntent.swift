//  ReceiveMessageIntent.swift

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
        print("\n📱 ReceiveMessageIntent started")
        print("   Body: \(bodyText)")
        
        let container = try ModelContainer(
            for: DreamWorms_iOS.Case.self, CaseLocation.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        let modelContext = ModelContext(container)
        
        // ✅ activeCase 가져오기 (에러 처리 강화)
        guard let activeCase = try fetchActiveCase(from: modelContext) else {
            print("❌ No active case found")
            // 활성 Case가 없으면 저장 불가
            return .result()
        }
        
        print("✅ Active case: \(activeCase.name) (ID: \(activeCase.id))")
        
        // 주소 추출
        guard let address = MessageParser.extractAddress(from: bodyText) else {
            print("⚠️ No valid address found, saving without geocoding")
            
            let location = CaseLocation(
                pinType: .telecom,
                receivedAt: Date().toKoreanTime
            )
            location.parentCase = activeCase
            modelContext.insert(location)
            
            try modelContext.save()
            print("✅ Saved location without address")
            return .result()
        }
        
        print("📍 Extracted address: \(address)")
        
        // 지오코딩
        do {
            let geocodeResult = try await GeocodeService.geocode(address: address)
            
            guard let latitude = geocodeResult.latitude,
                  let longitude = geocodeResult.longitude
            else {
                print("⚠️ Geocoding returned no coordinates")
                
                let location = CaseLocation(
                    pinType: .telecom,
                    address: address, // ✅ 주소는 저장
                    receivedAt: Date().toKoreanTime
                )
                location.parentCase = activeCase
                modelContext.insert(location)
                
                try modelContext.save()
                print("✅ Saved location with address only")
                return .result()
            }
            
            // ✅ 성공: 주소 + 좌표
            let location = CaseLocation(
                pinType: .telecom,
                address: geocodeResult.fullAddress,
                latitude: latitude,
                longitude: longitude,
                receivedAt: Date().toKoreanTime
            )
            location.parentCase = activeCase
            modelContext.insert(location)
            
            try modelContext.save()
            
            print("✅ Saved location successfully:")
            print("   - Address: \(geocodeResult.fullAddress)")
            print("   - Coords: (\(latitude), \(longitude))")
            print("   - Case: \(activeCase.name)")
            print("   - parentCase set: \(location.parentCase != nil)")
            
        } catch {
            print("❌ Geocoding failed: \(error)")
            
            let location = CaseLocation(
                pinType: .telecom,
                address: address, // ✅ 주소는 저장
                receivedAt: Date().toKoreanTime
            )
            location.parentCase = activeCase
            modelContext.insert(location)
            
            try modelContext.save()
            print("✅ Saved location after geocoding error")
        }
        
        return .result()
    }
    
    // ✅ activeCase 가져오기 (개선)
    @MainActor
    private func fetchActiveCase(from context: ModelContext) throws -> DreamWorms_iOS.Case? {
        // 1. UserDefaults에서 activeCase ID 가져오기
        guard let idString = UserDefaults.standard.string(forKey: "activeCase"),
              let activeCaseID = UUID(uuidString: idString)
        else {
            print("⚠️ No activeCase in UserDefaults, using first case")
            
            // ✅ Fallback: 첫 번째 Case 사용
            let descriptor = FetchDescriptor<DreamWorms_iOS.Case>()
            let allCases = try context.fetch(descriptor)
            
            if let firstCase = allCases.first {
                print("   Using first case: \(firstCase.name)")
                return firstCase
            }
            
            return nil
        }
        
        // 2. ID로 Case 찾기
        let descriptor = FetchDescriptor<DreamWorms_iOS.Case>(
            predicate: #Predicate { $0.id == activeCaseID }
        )
        
        return try context.fetch(descriptor).first
    }
}
