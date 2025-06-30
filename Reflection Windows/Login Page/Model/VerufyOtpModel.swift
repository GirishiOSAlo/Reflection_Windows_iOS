//
//  VerufyOtpModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 07/03/24.
//

import Foundation

// MARK: - Welcome
struct VerifyOtpModel: Codable {
    let data: VeryfyOtpResult?
    let uniqueID: String?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data
        case uniqueID = "unique_id"
        case success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct VeryfyOtpResult: Codable {
    
}
