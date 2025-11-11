//
//  Endpoint.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Alamofire

protocol Endpoint {
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}
