//
//  ChangePasswordModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 26/03/24.
//

import Foundation

// MARK: - Welcome
struct ChangePasswordModel: Codable {
    let data: ChangePasswordResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct ChangePasswordResult: Codable {
}
