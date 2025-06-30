//
//  DimensionDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 28/08/24.
//

import Foundation
struct DimensionDataModel: Codable {
    let data: [DimensionLimitDetails]?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - Datum
struct DimensionLimitDetails: Codable {
    let id, productID, categoryID: Int?
    let minWidth, maxWidth, widthInterval: Double?
    let minHeight, maxHeight, heightInterval: Double?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case categoryID = "category_id"
        case minWidth = "min_width"
        case maxWidth = "max_width"
        case widthInterval = "width_interval"
        case minHeight = "min_height"
        case maxHeight = "max_height"
        case heightInterval = "height_interval"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
