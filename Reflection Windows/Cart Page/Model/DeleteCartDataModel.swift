//
//  DeleteCartDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/03/24.
//

import Foundation

// MARK: - Welcome
struct DeleteCartDataModel: Codable {
    let data: DeleteCartResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct DeleteCartResult: Codable {
    
}
