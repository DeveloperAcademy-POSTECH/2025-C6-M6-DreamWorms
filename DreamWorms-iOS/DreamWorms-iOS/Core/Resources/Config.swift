//
//  Config.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import Foundation

enum Config {
    enum Keys {
        enum Plist {
            static let naverMapClientID = "NAVER_CLOUD_MAP_API_CLIENT_ID"
            static let naverMapClientSecret = "NAVER_CLOUD_MAP_API_CLIENT_SECRET"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found !!!")
        }
        return dict
    }()
}

extension Config {
    static let naverMapClientID: String = {
        guard let key = Config.infoDictionary[Keys.Plist.naverMapClientID] as? String else {
            fatalError("❌NAVER_CLOUD_MAP_API_CLIENT_ID is not set in plist for this configuration❌")
        }
        return key
    }()

    static let naverMapClientSecret: String = {
        guard let key = Config.infoDictionary[Keys.Plist.naverMapClientSecret] as? String else {
            fatalError("❌NAVER_CLOUD_MAP_API_CLIENT_SECRET is not set in plist for this configuration❌")
        }
        return key
    }()
}
