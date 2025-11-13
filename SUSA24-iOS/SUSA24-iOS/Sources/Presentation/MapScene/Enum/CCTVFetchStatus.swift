//
//  CCTVFetchStatus.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

enum CCTVFetchStatus: Equatable {
    case idle
    case fetching
    case failed(String)
}
