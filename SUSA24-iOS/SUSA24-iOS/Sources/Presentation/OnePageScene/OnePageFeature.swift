//
//  OnePageFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct OnePageFeature: DWReducer {
    private let categoryTypeMap: [Category: [Int]] = [
        .residence: [0], .workplace: [1], .others: [3], .all: [0, 1, 3],
    ]
    
    private let caseRepository: CaseRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol
    
    init(
        caseRepository: CaseRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol
    ) {
        self.caseRepository = caseRepository
        self.locationRepository = locationRepository
    }
    
    // MARK: - State
    
    struct State: DWState {
        var selection: Category = .all
        var caseID: UUID?
        var items: [Location] = []
        var suspectName: String = ""
        var crime: String = ""
        var suspectImage: UIImage?
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case selectionChanged(Category)
        case onAppear(UUID)
        case loadCaseInfo(UUID)
        case setCaseInfo(String, String, UIImage?)
        case loadLocations(UUID, Category)
        case setLocationItems([Location])
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .selectionChanged(category):
            state.selection = category
            guard let caseId = state.caseID else { return .none }
            return .task { [] in
                do {
                    return .loadLocations(caseId, category)
                } catch {
                    return .setLocationItems([])
                }
            }

        case let .onAppear(caseID):
            state.caseID = caseID
            let selection = state.selection
            return .merge(
                .task { .loadCaseInfo(caseID) },
                .task { .loadLocations(caseID, selection) }
            )
            
        case let .loadCaseInfo(caseID):
            return .task { [caseRepository] in
                do {
                    let result = try await caseRepository.fetchAllDataOfSpecificCase(for: caseID)
                    if let caseInfo = result.case {
                        let image: UIImage? = await {
                            guard let path = caseInfo.suspectProfileImage else { return nil }
                            return await ImageFileStorage.loadProfileImage(from: path)
                        }()
                        return .setCaseInfo(caseInfo.suspect, caseInfo.crime, image)
                    } else {
                        return .setCaseInfo("", "", nil)
                    }
                } catch {
                    return .setCaseInfo("", "", nil)
                }
            }
            
        case let .setCaseInfo(name, crime, image):
            state.suspectName = name
            state.crime = crime
            state.suspectImage = image
            return .none

        case let .loadLocations(caseID, selection):
            return .task { [locationRepository, categoryTypeMap] in
                do {
                    let types = categoryTypeMap[selection] ?? [0, 1, 3]
                    let locations = try await locationRepository.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: types
                    )
                    return .setLocationItems(locations)
                } catch {
                    return .setLocationItems([])
                }
            }
            
        case let .setLocationItems(locations):
            state.items = locations
            return .none
        }
    }
}
