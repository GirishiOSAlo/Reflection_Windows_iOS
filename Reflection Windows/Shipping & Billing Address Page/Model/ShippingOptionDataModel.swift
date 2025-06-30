//
//  ShippingOptionDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 13/03/24.
//

import Foundation

struct ShippingOptionDataModel: Codable {
    let data: ShippingOptionResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct ShippingOptionResult: Codable {
    let options: [ShippingOptionData]?
}

// MARK: - Option
struct ShippingOptionData: Codable {
    let id: Int?
    let type, date: String?
    let amount: String?
}
