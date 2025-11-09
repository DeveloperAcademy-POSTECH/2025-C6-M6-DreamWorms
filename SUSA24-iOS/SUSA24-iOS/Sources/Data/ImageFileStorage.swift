//
//  ImageFileStorage.swift
//  SUSA24-iOS
//
//  Created by mini on 11/9/25.
//

import UIKit

enum ImageFileStorage {
    /// Images 디렉토리의 BASE URL
    private static func imageBaseURL() throws -> URL {
        let manager = FileManager.default
        let document = try manager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = document.appendingPathComponent("Images", isDirectory: true)

        if !manager.fileExists(atPath: directory.path) {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }
    
    /// 프로필 이미지를 디스크에 저장하고, 경로(String)를 반환합니다.
    static func saveProfileImage(_ data: Data, for id: UUID) throws -> String {
        let fileName = "suspect_\(id.uuidString).jpg"
        let url = try imageBaseURL().appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    /// 저장된 파일 경로에서 실제 UIImage를 로드해옵니다.
    static func loadProfileImage(from path: String) -> UIImage? {
        guard let url = try? imageBaseURL().appendingPathComponent(path),
              FileManager.default.fileExists(atPath: url.path)
        else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// 이미지 파일을 삭제합니다. (케이스/용의자 삭제 시 호출)
    static func deleteProfileImage(at path: String) {
        guard let url = try? imageBaseURL().appendingPathComponent(path) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
