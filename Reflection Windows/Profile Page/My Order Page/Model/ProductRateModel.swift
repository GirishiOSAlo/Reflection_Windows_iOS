//
//  ProductRateModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/04/24.
//

import Foundation

// MARK: - Welcome
struct ProductRateModel: Codable {
    var data: ProductRateResult?
    var success: Bool?
    var message: String?
    var statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct ProductRateResult: Codable {
}
