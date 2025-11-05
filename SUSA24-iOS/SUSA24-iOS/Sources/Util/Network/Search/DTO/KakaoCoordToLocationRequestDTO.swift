//
//  KakaoCoordToLocationRequestDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Foundation

nonisolated struct KakaoCoordToLocationRequestDTO: Encodable, Sendable {
    let x: String
    let y: String
    let inputCoord: String?
}
