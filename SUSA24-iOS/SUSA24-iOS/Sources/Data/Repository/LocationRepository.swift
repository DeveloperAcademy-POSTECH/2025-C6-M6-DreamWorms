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
    
    //
    func fetchTopLocations(
        caseId: UUID,
        limit: Int,
        in range: ClosedRange<Date>?
    ) async throws -> [LocationRank]

    // ✅ 추가: 특정 주소·요일·주차의 0~23시 시리즈
    func fetchHourlySeries(
        caseId: UUID,
        address: String,
        weekday: Int,          // Foundation 요일(일=1 … 토=7). Weekday enum 쓰면 매핑해서 넘겨줘.
        slice: WeekSlice,
        calendar: Calendar
    ) async throws -> [HourValue]

    // ✅ 추가: 지난주/이번주 한 번에 가져오기(편의)
    func fetchWeeklySeries(
        caseId: UUID,
        address: String,
        weekday: Int,
        calendar: Calendar
    ) async throws -> (lastWeek: [HourValue], thisWeek: [HourValue])
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
                  let suspect = suspectsSet.first else {
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
    
    func fetchTopLocations(
        caseId: UUID,
        limit: Int = 3,
        in range: ClosedRange<Date>? = nil
    ) async throws -> [LocationRank] {
        try await context.perform {
            let req = NSFetchRequest<NSDictionary>(entityName: "LocationEntity")
            req.resultType = .dictionaryResultType

            // suspect.case.id == caseId 로 바로 필터
            var predicates: [NSPredicate] = [
                NSPredicate(format: "suspect.case.id == %@", caseId as CVarArg)
            ]
            if let range {
                predicates.append(NSPredicate(format: "receivedAt >= %@ AND receivedAt < %@",
                                              range.lowerBound as NSDate, range.upperBound as NSDate))
            }
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

            // GROUP BY address
            req.propertiesToGroupBy = ["address"]

            // COUNT(id)
            let countDesc = NSExpressionDescription()
            countDesc.name = "cnt"
            countDesc.expression = NSExpression(forFunction: "count:",
                                                arguments: [NSExpression(forKeyPath: "id")])
            countDesc.expressionResultType = .integer64AttributeType

            req.propertiesToFetch = ["address", countDesc]
            req.sortDescriptors = [NSSortDescriptor(key: "cnt", ascending: false)]
            req.fetchLimit = max(0, limit)

            let rows = try context.fetch(req)
            return rows.compactMap { dict in
                guard let address = dict["address"] as? String,
                      let cnt = dict["cnt"] as? Int else { return nil }
                return LocationRank(address: address, count: cnt)
            }
        }
    }

    // MARK: - Hourly series (0~23)

    func fetchHourlySeries(
        caseId: UUID,
        address: String,
        weekday: Int,
        slice: WeekSlice,
        calendar: Calendar = .current
    ) async throws -> [HourValue] {
        try await context.perform {
            // 주(week) 구간 계산
            var cal = calendar
            if cal.firstWeekday != 2 { cal.firstWeekday = 2 } // 월요일 시작(원하면 바꿔도 됨)

            let now = Date()
            let startOfThisWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!

            let start: Date
            switch slice {
            case .thisWeek:
                start = startOfThisWeek
            case .lastWeek:
                start = cal.date(byAdding: .day, value: -7, to: startOfThisWeek)!
            }

            let end = cal.date(byAdding: .day, value: 7, to: start)!

            // 해당 주 + 케이스 + 주소
            let req = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "suspect.case.id == %@", caseId as CVarArg),
                NSPredicate(format: "address == %@", address),
                NSPredicate(format: "receivedAt >= %@ AND receivedAt < %@", start as NSDate, end as NSDate)
            ])
            // 메모리 절약: 필요한 컬럼만 fault로 가져오게 힌트
            req.returnsObjectsAsFaults = true

            let rows = try context.fetch(req)

            // 0~23 카운트
            var buckets = Array(repeating: 0, count: 24)

            for r in rows {
                guard let date = r.receivedAt else { continue }
                // 선택 요일만
                let w = cal.component(.weekday, from: date) // 일=1 … 토=7
                guard w == weekday else { continue }

                let h = cal.component(.hour, from: date)
                if (0..<24).contains(h) { buckets[h] &+= 1 }
            }

            return (0..<24).map { HourValue(hour: $0, value: Double(buckets[$0])) }
        }
    }

    // MARK: - Convenience: 지난주/이번주 동시

    func fetchWeeklySeries(
        caseId: UUID,
        address: String,
        weekday: Int,
        calendar: Calendar = .current
    ) async throws -> (lastWeek: [HourValue], thisWeek: [HourValue]) {
        async let last = fetchHourlySeries(caseId: caseId, address: address, weekday: weekday, slice: .lastWeek, calendar: calendar)
        async let this = fetchHourlySeries(caseId: caseId, address: address, weekday: weekday, slice: .thisWeek, calendar: calendar)
        return try await (last, this)
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
    func fetchLocations(caseId: UUID) async throws -> [Location] { [] }
    func deleteLocation(id: UUID) async throws {}
    func createLocations(data: [Location], caseId: UUID) async throws {}
    func fetchTopLocations(caseId: UUID, limit: Int, in range: ClosedRange<Date>?) async throws -> [LocationRank] { [] }
    func fetchHourlySeries(caseId: UUID, address: String, weekday: Int, slice: WeekSlice, calendar: Calendar) async throws -> [HourValue] { [] }
    func fetchWeeklySeries(caseId: UUID, address: String, weekday: Int, calendar: Calendar) async throws -> (lastWeek: [HourValue], thisWeek: [HourValue]) { ([], []) }
}

