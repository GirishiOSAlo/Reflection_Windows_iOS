//
//  SendOtpModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 07/03/24.
//

import Foundation

// MARK: - Welcome
struct SendOtpModel: Codable {
    let data: SendOtpResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct SendOtpResult: Codable {
}
