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
}

// TODO: - Preview용 Mock Repository

struct MockCaseRepository: CaseRepositoryProtocol {
    func fetchCases() async throws -> [Case] { [] }
    func deleteCase(id: UUID) async throws {}
    func createCase(model: Case) async throws {}
}
