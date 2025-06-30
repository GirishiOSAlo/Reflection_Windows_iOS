//
//  AddAddressDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/03/24.
//

import Foundation

// MARK: - Welcome
struct AddAddressDataModel: Codable {
    let data: AddAddressResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct AddAddressResult: Codable {
    var city, addressLine2, email, pincode: String?
    var name, state, addressLine1: String?
    var mobileNumber, shippingBillingAddress: String?
    var userID, defaultAddress: Int?
    var updatedAt, createdAt: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case city
        case addressLine2 = "address_line_2"
        case email, pincode, name, state
        case defaultAddress = "default_address"
        case addressLine1 = "address_line_1"
        case mobileNumber = "mobile_number"
        case shippingBillingAddress = "shipping_billing_address"
        case userID = "user_id"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}
