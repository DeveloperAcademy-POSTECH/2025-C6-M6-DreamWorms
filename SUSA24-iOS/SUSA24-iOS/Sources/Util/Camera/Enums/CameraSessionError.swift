//
//  CameraSessionError.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import Foundation

// MARK: - Error

/// 카메라 세션 캡쳐 과정의 에러 상태

enum CameraSessionError: LocalizedError {
    case failedToAddInput
    case failedToAddOutput
    case sessionNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .failedToAddInput:
            "카메라 입력을 세션에 추가할 수 없습니다."
        case .failedToAddOutput:
            "카메라 출력을 세션에 추가할 수 없습니다."
        case .sessionNotConfigured:
            "캡처 세션이 구성되지 않았습니다."
        }
    }
}
