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
    func createCase(model: Case) async throws
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
                Case(
                    id: $0.id ?? UUID(),
                    number: $0.number ?? "",
                    name: $0.name ?? "",
                    crime: $0.crime ?? "",
                    // TODO: - 범죄자 정보 가져오도록 추후 코드에서 수정하기
                    suspect: ""
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
                   let suspect = suspectsSet.first else {
                 return (nil, [])
             }
             
             // Case 정보 생성
             let caseInfo = Case(
                 id: caseEntity.id ?? UUID(),
                 number: caseEntity.number ?? "",
                 name: caseEntity.name ?? "",
                 crime: caseEntity.crime ?? "",
                 suspect: suspect.name ?? ""
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
                     receivedAt: locationEntity.receivedAt,
                     colorType: locationEntity.colorType
                 )
             }
             
             return (caseInfo, locations)
         }
     }
    
    func deleteCase(id: UUID) async throws {
        try await context.perform {
            let req = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let target = try context.fetch(req).first {
                context.delete(target)
                try context.save()
            }
        }
    }
    
    func createCase(model: Case) async throws {
        try await context.perform {
            let caseEntity = CaseEntity(context: context)
            caseEntity.id = UUID()
            caseEntity.name = model.name
            caseEntity.number = model.number
            caseEntity.suspects
            caseEntity.crime = model.crime
            
            let suspectEntity = SuspectEntity(context: context)
            suspectEntity.id = UUID()
            suspectEntity.name = model.suspect
            suspectEntity.profileImage = model.suspectProfileImage
            
            suspectEntity.relateCase = caseEntity
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
}

// TODO: - Preview용 Mock Repository

struct MockCaseRepository: CaseRepositoryProtocol {
    func fetchCases() async throws -> [Case] { [] }
    func fetchAllDataOfSpecificCase(for caseId: UUID) async throws -> (case: Case?, location: [Location]) {
        return (nil, [])
    }
    func loadMockDataIfNeeded(caseId: UUID) async throws {}
    func deleteCase(id: UUID) async throws {}
    func createCase(model: Case) async throws {}
}
