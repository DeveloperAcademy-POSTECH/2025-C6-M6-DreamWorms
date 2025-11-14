//
//  CapturedPhoto+.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import UIKit

// MARK: - CameraScene 에서만 사용하는 CapturedPhoto Extensions

extension CapturedPhoto {
    /// 사진 데이터를 UIImage로 변환합니다.
    var uiImage: UIImage? {
        UIImage(data: data)
    }
}

// MARK: - Hashable

extension CapturedPhoto: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Equatable

extension CapturedPhoto: Equatable {
    static func == (lhs: CapturedPhoto, rhs: CapturedPhoto) -> Bool {
        lhs.id == rhs.id
    }
}
