//
//  CaseRepository.swift
//  SUSA24-iOS
//
//  Created by mini on 11/1/25.
//

import CoreData

// MARK: - Repository Protocol

protocol CaseRepositoryProtocol: Sendable {
    func fetchCases() async throws -> [Case]
    
    /// 특정 케이스의 상세 정보를 조회합니다.
    ///
    /// Case 정보, 용의자 정보, 모든 Location을 한 번에 가져옵니다.
    /// - Parameter id: 조회할 케이스의 UUID
    /// - Returns: (Case 정보, Location 배열) 튜플. 케이스가 없으면 (nil, []) 반환
    /// - Throws: CoreData 조회 에러
    func fetchAllDataOfSpecificCase(for caseId: UUID) async throws -> (case: Case?, location: [Location])
    
    /// 테스트용 목데이터를 저장합니다. 기존 데이터가 있으면 저장하지 않습니다.
    /// - Parameter caseId: 저장할 Case의 UUID
    /// - Throws: CoreData 저장 에러
    func loadMockDataIfNeeded(caseId: UUID) async throws
    
    func deleteCase(id: UUID) async throws
    func createCase(model: Case, imageData: Data?, phoneNumber: String?) async throws

    /// 전화번호로 케이스를 찾습니다.
    /// - Parameter phoneNumber: 피의자 전화번호
    /// - Returns: 매칭되는 케이스 ID. 없으면 nil
    /// - Throws: CoreData 조회 에러
    func findCaseByPhoneNumber(_ phoneNumber: String) async throws -> UUID?
}

// MARK: - Repository Implementation

struct CaseRepository: CaseRepositoryProtocol {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    func fetchCases() async throws -> [Case] {
        try await context.perform {
            let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            let results = try context.fetch(request)
            return results.map {
                let suspects = ($0.suspects as? Set<SuspectEntity>) ?? []
                let primarySuspect = suspects.first
                
                return Case(
                    id: $0.id ?? UUID(),
                    number: $0.number ?? "",
                    name: $0.name ?? "",
                    crime: $0.crime ?? "",
                    suspect: primarySuspect?.name ?? "",
                    suspectProfileImage: primarySuspect?.profileImage
                )
            }
        }
    }
    
    func fetchAllDataOfSpecificCase(for caseId: UUID) async throws -> (case: Case?, location: [Location]) {
        try await context.perform {
            let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            request.predicate = NSPredicate(format: "id == %@", caseId as CVarArg)
            
            guard let caseEntity = try context.fetch(request).first else {
                return (nil, [])
            }
            
            // Suspect 정보 가져오기 (한 명만 가정)
            guard let suspectsSet = caseEntity.suspects as? Set<SuspectEntity>,
                  let suspect = suspectsSet.first
            else {
                return (nil, [])
            }
            
            // Case 정보 생성
            let caseInfo = Case(
                id: caseEntity.id ?? UUID(),
                number: caseEntity.number ?? "",
                name: caseEntity.name ?? "",
                crime: caseEntity.crime ?? "",
                suspect: suspect.name ?? "",
                suspectProfileImage: suspect.profileImage
            )
            
            // 해당 Suspect의 모든 Location 가져오기
            guard let locationsSet = suspect.locations as? Set<LocationEntity> else {
                return (caseInfo, [])
            }
            
            let locations = locationsSet.compactMap { locationEntity -> Location? in
                guard let locationId = locationEntity.id else { return nil }
                return Location(
                    id: locationId,
                    address: locationEntity.address ?? "",
                    title: locationEntity.title,
                    note: locationEntity.note,
                    pointLatitude: locationEntity.pointLatitude,
                    pointLongitude: locationEntity.pointLongitude,
                    boxMinLatitude: locationEntity.boxMinLatitude == 0.0 ? nil : locationEntity.boxMinLatitude,
                    boxMinLongitude: locationEntity.boxMinLongitude == 0.0 ? nil : locationEntity.boxMinLongitude,
                    boxMaxLatitude: locationEntity.boxMaxLatitude == 0.0 ? nil : locationEntity.boxMaxLatitude,
                    boxMaxLongitude: locationEntity.boxMaxLongitude == 0.0 ? nil : locationEntity.boxMaxLongitude,
                    locationType: locationEntity.locationType,
                    colorType: locationEntity.colorType,
                    receivedAt: locationEntity.receivedAt
                )
            }
            
            return (caseInfo, locations)
        }
    }
    
    func deleteCase(id: UUID) async throws {
        try await context.perform {
            let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let target = try context.fetch(request).first {
                if let suspects = target.suspects as? Set<SuspectEntity> {
                    suspects.forEach { suspect in
                        // suspect들의 profileImagePath도 함께 삭제합니다.
                        if let path = suspect.profileImage {
                            ImageFileStorage.deleteProfileImage(at: path)
                        }
                    }
                }
                context.delete(target)
                try context.save()
            }
        }
    }
    
    func createCase(model: Case, imageData: Data?, phoneNumber: String?) async throws {
        try await context.perform {
            let caseEntity = CaseEntity(context: context)
            caseEntity.id = model.id
            caseEntity.name = model.name
            caseEntity.number = model.number
            caseEntity.crime = model.crime

            let suspectEntity = SuspectEntity(context: context)
            suspectEntity.id = UUID()
            suspectEntity.name = model.suspect
            suspectEntity.phoneNumber = phoneNumber
            suspectEntity.relateCase = caseEntity

            if let data = imageData,
               let path = try? ImageFileStorage.saveProfileImage(
                   data,
                   for: suspectEntity.id ?? UUID()
               )
            {
                // 이미지 경로만 CoreData에 보관
                suspectEntity.profileImage = path
            }

            caseEntity.addToSuspects(suspectEntity)
            try context.save()
        }
    }
    
    /// 테스트용 목데이터를 저장합니다. 기존 데이터가 있으면 저장하지 않습니다.
    /// - Parameter caseId: 저장할 Case의 UUID
    /// - Throws: CoreData 저장 에러
    func loadMockDataIfNeeded(caseId: UUID) async throws {
        // 이미 Location 데이터가 있는지 확인
        let (_, existingLocations) = try await fetchAllDataOfSpecificCase(for: caseId)
        guard existingLocations.isEmpty else {
            print(" [CaseRepository] 이미 Location 데이터가 있습니다. 목데이터를 로드하지 않습니다.")
            return
        }
        
        print("⚠️ [CaseRepository] Location 데이터가 없습니다. 목데이터를 로드합니다...")
        
        // LocationRepository를 통해 목데이터 로드
        let locationRepository = LocationRepository(context: context)
        try await locationRepository.loadMockDataIfNeeded(caseId: caseId)
        
        print("✅ [CaseRepository] 목데이터 로드 완료")
    }

    // MARK: - 전화번호로 케이스 찾기

    /// 전화번호로 케이스를 찾습니다.
    /// - Parameter phoneNumber: 피의자의 위치 데이터를 받아오는 폰번호
    /// - Returns: 매칭되는 케이스 ID. 없으면 nil
    /// - Throws: CoreData 조회 에러
    func findCaseByPhoneNumber(_ phoneNumber: String) async throws -> UUID? {
        try await context.perform {
            // 모든 케이스 가져오기
            let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            let cases = try context.fetch(request)

            // 전화번호 정규화 (하이픈 제거)
            let normalizedInput = phoneNumber.replacingOccurrences(of: "-", with: "")

            // 각 케이스의 피의자 전화번호와 비교
            for caseEntity in cases {
                guard let suspects = caseEntity.suspects as? Set<SuspectEntity> else {
                    continue
                }

                for suspect in suspects {
                    if let suspectPhone = suspect.phoneNumber {
                        let normalizedSuspectPhone = suspectPhone.replacingOccurrences(of: "-", with: "")
                        if normalizedSuspectPhone == normalizedInput {
                            return caseEntity.id
                        }
                    }
                }
            }

            return nil
        }
    }
}

// TODO: - Preview용 Mock Repository

struct MockCaseRepository: CaseRepositoryProtocol {
    func fetchCases() async throws -> [Case] { [] }
    func fetchAllDataOfSpecificCase(for _: UUID) async throws -> (case: Case?, location: [Location]) {
        (nil, [])
    }

    func loadMockDataIfNeeded(caseId _: UUID) async throws {}
    func deleteCase(id _: UUID) async throws {}
    func createCase(model _: Case, imageData _: Data?, phoneNumber _: String?) async throws {}

    func findCaseByPhoneNumber(_: String) async throws -> UUID? { nil }
}
