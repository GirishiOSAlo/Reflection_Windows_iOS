//
//  DeleteWishListDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/03/24.
//

import Foundation

// MARK: - Welcome
struct DeleteWishListDataModel: Codable {
    let data: DeleteWishListResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct DeleteWishListResult: Codable {
}
