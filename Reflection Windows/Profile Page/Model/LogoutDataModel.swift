//
//  LogoutDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/03/24.
//

import Foundation

// MARK: - Welcome
struct LogoutDataModel: Codable {
    let data: LogoutDataResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct LogoutDataResult: Codable {
}
