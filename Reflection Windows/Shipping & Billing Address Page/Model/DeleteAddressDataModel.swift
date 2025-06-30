//
//  DeleteAddressDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 13/03/24.
//

import Foundation

struct DeleteAddressDataModel: Codable {
    let data: DeleteAddressResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct DeleteAddressResult: Codable {
}
