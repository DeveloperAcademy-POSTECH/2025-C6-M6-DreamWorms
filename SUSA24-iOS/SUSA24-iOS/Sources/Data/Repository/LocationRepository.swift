//
//  LocationRepository.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/3/25.
//

import CoreData

// MARK: - Repository Protocol

protocol LocationRepositoryProtocol: Sendable {
    /// 특정 Case의 모든 Location을 조회합니다.
    /// - Parameter caseId: 조회할 Case의 UUID
    /// - Returns: Location 배열
    /// - Throws: CoreData 조회 에러
    func fetchLocations(caseId: UUID) async throws -> [Location]
    
    /// 특정 Case의 "특정 LocationType"의 Location을 조회합니다.
    /// - Parameters:
    ///   - caseId: 조회할 Case의 UUID
    ///   - locationType: 조회할 LocationType에 해당하는 배열 ([Int])
    /// - Returns: Location 배열
    /// - Throws: CoreData 조회 에러
    func fetchNoCellLocations(caseId: UUID, locationType: [Int]) async throws -> [Location]
    
    /// Location을 삭제합니다.
    /// - Parameter id: 삭제할 Location의 UUID
    /// - Throws: CoreData 삭제 에러
    func deleteLocation(id: UUID) async throws
    
    /// Location 배열을 생성하고 Case의 첫 번째 Suspect와 연결합니다.
    /// - Parameters:
    ///   - data: 생성할 Location 데이터 배열
    ///   - caseId: 연결할 Case의 UUID (케이스당 suspect가 한 명이라는 가정)
    /// - Throws: CoreData 저장 에러 (Case 또는 Suspect를 찾을 수 없는 경우 포함)
    func createLocations(data: [Location], caseId: UUID) async throws
}

// MARK: - Repository Implementation

struct LocationRepository: LocationRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// 특정 Case의 모든 Location을 조회합니다.
    /// Case → Suspects → Locations 관계를 통해 접근합니다.
    /// - Parameter caseId: 조회할 Case의 UUID
    /// - Returns: Location 배열 (Case가 없거나 Location이 없으면 빈 배열 반환)
    /// - Throws: CoreData 조회 에러
    func fetchLocations(caseId: UUID) async throws -> [Location] {
        try await context.perform {
            let caseRequest = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            caseRequest.predicate = NSPredicate(format: "id == %@", caseId as CVarArg)
            
            guard let caseEntity = try context.fetch(caseRequest).first else { return [] }
            guard let suspectsSet = caseEntity.suspects as? Set<SuspectEntity> else { return [] }
            
            var locations: [LocationEntity] = []
            for suspect in suspectsSet {
                if let locationsSet = suspect.locations as? Set<LocationEntity> {
                    locations.append(contentsOf: locationsSet)
                }
            }
            return locations.compactMap { locationEntity -> Location? in
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
        }
    }
    
    /// 특정 Case의 "특정 LocationType"의 Location을 조회합니다.
    /// - Parameters:
    ///   - caseId: 조회할 Case의 UUID
    ///   - locationType: 조회할 LocationType에 해당하는 배열 ([Int])
    /// - Returns: Location 배열
    /// - Throws: CoreData 조회 에러
    func fetchNoCellLocations(caseId: UUID, locationType: [Int]) async throws -> [Location] {
        try await context.perform {
            let caseRequest = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            caseRequest.predicate = NSPredicate(format: "id == %@", caseId as CVarArg)
            
            guard let caseEntity = try context.fetch(caseRequest).first else { return [] }
            guard let suspectsSet = caseEntity.suspects as? Set<SuspectEntity> else { return [] }
            
            var locations: [LocationEntity] = []
            for suspect in suspectsSet {
                if let locationsSet = suspect.locations as? Set<LocationEntity> {
                    locations.append(contentsOf: locationsSet.filter { location in
                        locationType.contains(Int(location.locationType))
                    })
                }
            }
            
            return locations.compactMap { locationEntity -> Location? in
                guard let id = locationEntity.id else { return nil }
                return Location(
                    id: id,
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
        }
    }
    
    /// Location을 삭제합니다.
    /// - Parameter id: 삭제할 Location의 UUID
    /// - Throws: CoreData 삭제 에러
    func deleteLocation(id: UUID) async throws {
        try await context.perform {
            let request = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            guard let locationEntity = try context.fetch(request).first else { return }
            context.delete(locationEntity)
            try context.save()
        }
    }
    
    /// Location 배열을 생성하고 Case의 첫 번째 Suspect와 연결합니다.
    /// 모든 Location을 한 번의 트랜잭션으로 저장합니다.
    /// - Parameters:
    ///   - data: 생성할 Location 데이터 배열 ([Location])
    ///   - caseId: 연결할 Case의 UUID (케이스당 suspect가 한 명이라는 가정)
    /// - Throws:
    ///   - NSError (code: 1): Case를 찾을 수 없는 경우
    ///   - NSError (code: 2): Suspect를 찾을 수 없는 경우
    ///   - CoreData 저장 에러
    func createLocations(data: [Location], caseId: UUID) async throws {
        guard !data.isEmpty else { return }
        
        try await context.perform {
            let caseRequest = NSFetchRequest<CaseEntity>(entityName: "CaseEntity")
            caseRequest.predicate = NSPredicate(format: "id == %@", caseId as CVarArg)
            
            guard let caseEntity = try context.fetch(caseRequest).first else {
                throw NSError(domain: "LocationRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Case not found"])
            }
            
            guard let suspectsSet = caseEntity.suspects as? Set<SuspectEntity>,
                  let suspect = suspectsSet.first
            else {
                throw NSError(domain: "LocationRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "Suspect not found"])
            }
            
            for location in data {
                let locationEntity = LocationEntity(context: context)
                locationEntity.id = location.id
                locationEntity.address = location.address
                locationEntity.title = location.title
                locationEntity.note = location.note
                locationEntity.pointLatitude = location.pointLatitude
                locationEntity.pointLongitude = location.pointLongitude
                locationEntity.boxMinLatitude = location.boxMinLatitude ?? 0.0
                locationEntity.boxMinLongitude = location.boxMinLongitude ?? 0.0
                locationEntity.boxMaxLatitude = location.boxMaxLatitude ?? 0.0
                locationEntity.boxMaxLongitude = location.boxMaxLongitude ?? 0.0
                locationEntity.locationType = location.locationType
                locationEntity.receivedAt = location.receivedAt
                locationEntity.suspect = suspect
            }
            
            try context.save()
        }
    }
    
    /// 테스트용 목데이터를 저장합니다. 기존 데이터가 있으면 저장하지 않습니다.
    /// - Parameter caseId: 저장할 Case의 UUID
    /// - Throws: JSONLoaderError, CoreData 저장 에러
    func loadMockDataIfNeeded(caseId: UUID) async throws {
        let existingLocations = try await fetchLocations(caseId: caseId)
        guard existingLocations.isEmpty else { return }
        try await LocationMockLoader.loadAndSaveToCoreData(caseId: caseId, context: context)
    }
}

struct MockLocationRepository: LocationRepositoryProtocol {
    func fetchLocations(caseId _: UUID) async throws -> [Location] { [] }
    func fetchNoCellLocations(caseId _: UUID, locationType _: [Int]) async throws -> [Location] { [] }
    func deleteLocation(id _: UUID) async throws {}
    func createLocations(data _: [Location], caseId _: UUID) async throws {}
}
