//
//  ZipcallDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 22/04/24.
//

import Foundation

// MARK: - Welcome
struct ZipcallDataModel: Codable {
    var data: ZipcallDataResult?
    var success: Bool?
    var message: String?
    var statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct ZipcallDataResult: Codable {
    var zipcode, city, state, telephoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case zipcode, city, state
        case telephoneNumber = "telephone_number"
    }
}
