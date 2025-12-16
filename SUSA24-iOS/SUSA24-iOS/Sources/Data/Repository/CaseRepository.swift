//
//  CaseRepository.swift
//  SUSA24-iOS
//
//  Created by mini on 11/1/25.
//

import CoreData

// MARK: - Repository Protocol

protocol CaseRepositoryProtocol: Sendable {
    func createCase(model: Case, imageData: Data?, phoneNumber: String?) async throws
    func fetchCases() async throws -> [Case]
    func updateCase(model: Case, imageData: Data?, phoneNumber: String?) async throws
    func deleteCase(id: UUID) async throws
    
    /// 특정 케이스의 상세 정보를 조회합니다.
    ///
    /// Case 정보, 용의자 정보, 모든 Location을 한 번에 가져옵니다.
    /// - Parameter id: 조회할 케이스의 UUID
    /// - Returns: (Case 정보, Location 배열) 튜플. 케이스가 없으면 (nil, []) 반환
    /// - Throws: CoreData 조회 에러
    func fetchAllDataOfSpecificCase(for caseId: UUID) async throws -> (case: Case?, location: [Location])
    
    /// CaseID 값을 기준으로 Case의 정보를 찾습니다.
    func fetchCaseForEdit(for caseId: UUID) async throws -> (case: Case?, phoneNumber: String?, profileImagePath: String?)
    
    /// 사건번호로 케이스를 찾습니다.
    /// - Parameter caseNumber: 사건번호(number)
    /// - Returns: 매칭되는 케이스 ID. 없으면 nil
    /// - Throws: CoreData 조회 에러
    func findCase(byCaseNumber caseNumber: String) async throws -> UUID?
    
    /// Test 코드
    /// 휴대폰 전화번호로 케이스를 찾습니다.
    /// - Parameter casePhoneNumber: 용의자 추적 전화번호 ( SuspectEntity.phoneNumber)
    /// - Returns: 매칭되는 케이스ID. 없으면 nil
    /// - Throws: CoreData 조회 에러
    func findCaseTest(byCasePhoneNumber phoneNumber: String) async throws -> UUID?
}

// MARK: - Repository Implementation

struct CaseRepository: CaseRepositoryProtocol {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }
    
    func createCase(
        model: Case,
        imageData: Data?,
        phoneNumber: String?
    ) async throws {
        let caseEntity = CaseEntity(context: context)
        caseEntity.id = model.id
        caseEntity.name = model.name
        caseEntity.number = model.number
        caseEntity.crime = model.crime
        
        let suspectEntity = SuspectEntity(context: context)
        let suspectId = UUID()
        suspectEntity.id = suspectId
        suspectEntity.name = model.suspect
        suspectEntity.phoneNumber = phoneNumber
        suspectEntity.relateCase = caseEntity
        
        if let imageData {
            if let path = try? ImageFileStorage.saveProfileImage(imageData, for: suspectId) {
                // 이미지 경로만 CoreData에 보관
                suspectEntity.profileImage = path
            }
        }
        caseEntity.addToSuspects(suspectEntity)
        try context.save()
    }
    
    func fetchCases() async throws -> [Case] {
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
    
    func updateCase(
        model: Case,
        imageData: Data?,
        phoneNumber: String?
    ) async throws {
        let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
        request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
        
        guard let caseEntity = try context.fetch(request).first else {
            return
        }
        
        caseEntity.name = model.name
        caseEntity.number = model.number
        caseEntity.crime = model.crime
        
        if let suspects = caseEntity.suspects as? Set<SuspectEntity>,
           let suspectEntity = suspects.first
        {
            suspectEntity.name = model.suspect
            suspectEntity.phoneNumber = phoneNumber
            
            // 이미지 업데이트 (imageData가 nil이면 기존 이미지 유지)
            if let data = imageData {
                // 기존 이미지 경로가 있으면 삭제
                if let oldPath = suspectEntity.profileImage {
                    ImageFileStorage.deleteProfileImage(at: oldPath)
                }
                // 새 이미지 저장
                let id = suspectEntity.id ?? UUID()
                if let newPath = try? ImageFileStorage.saveProfileImage(data, for: id) {
                    suspectEntity.profileImage = newPath
                }
            }
        }
        
        try context.save()
    }
    
    func deleteCase(id: UUID) async throws {
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
    
    func fetchAllDataOfSpecificCase(for caseId: UUID) async throws -> (case: Case?, location: [Location]) {
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
    
    func fetchCaseForEdit(
        for caseId: UUID
    ) async throws -> (case: Case?, phoneNumber: String?, profileImagePath: String?) {
        let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
        request.predicate = NSPredicate(format: "id == %@", caseId as CVarArg)
        
        guard let caseEntity = try context.fetch(request).first else {
            return (nil, nil, nil)
        }
        
        let suspects = (caseEntity.suspects as? Set<SuspectEntity>) ?? []
        let primarySuspect = suspects.first
        
        let caseModel = Case(
            id: caseEntity.id ?? caseId,
            number: caseEntity.number ?? "",
            name: caseEntity.name ?? "",
            crime: caseEntity.crime ?? "",
            suspect: primarySuspect?.name ?? "",
            suspectProfileImage: primarySuspect?.profileImage
        )
        
        let phoneNumber = primarySuspect?.phoneNumber
        let profileImagePath = primarySuspect?.profileImage
        
        return (caseModel, phoneNumber, profileImagePath)
     }
    
    /// 사건번호로 케이스를 찾습니다.
    /// - Parameter caseNumber: 사건번호
    /// - Returns: 매칭되는 케이스 ID. 없으면 nil
    /// - Throws: CoreData 조회 에러
    /// - Complexity: O(n) where n is the number of cases
    func findCase(byCaseNumber caseNumber: String) async throws -> UUID? {
        let request = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
        request.predicate = NSPredicate(format: "number == %@", caseNumber)
        
        let results = try context.fetch(request)
        return results.first?.id
    }
    
    /// 휴대전화 번호로 케이스ID를 찾습니다.
    /// Suspect의 phoneNumber: 용의자 휴대전화번호
    /// - Parameter phoneNumber: 용의자 휴대전화번호
    /// - Returns: 매칭되는 케이스 ID , 없으면 nil
    /// - Throws: CoreData 조회 에러
    /// - Complexity: O(N) where n is the number of suspects
    /// - Note: Suspectentity -> CaseEntity 로 추적합니다.
    func findCaseTest(byCasePhoneNumber phoneNumber: String) async throws -> UUID? {
        let request = NSFetchRequest<SuspectEntity>(entityName: "SuspectEntity")
        request.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        request.fetchLimit = 1
        
        let results = try context.fetch(request)
        return results.first?.relateCase?.id
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
    func fetchCaseForEdit(for _: UUID) async throws -> (case: Case?, phoneNumber: String?, profileImagePath: String?) {
        (nil, nil, nil)
    }
    
    func updateCase(model _: Case, imageData _: Data?, phoneNumber _: String?) async throws {}
    
    func findCase(byCaseNumber _: String) async throws -> UUID? { nil }
    
    /// Test Code For PhoneNumber
    func findCaseTest(byCasePhoneNumber _: String) async throws -> UUID? { nil }
}
