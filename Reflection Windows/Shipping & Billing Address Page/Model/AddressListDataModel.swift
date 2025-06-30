//
//  AddressListDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/03/24.
//

import Foundation

// MARK: - Welcome
struct AddressListDataModel: Codable {
    let data: AddressListResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct AddressListResult: Codable {
    let customerAddress: [CustomerAddress]?
}

// MARK: - CustomerAddress
struct CustomerAddress: Codable {
    let id, userID: Int?
    let addressRef, makaniNumber, location: String?
    let apartment, name, email, mobileNumber: String?
    let pincode, addressLine1: String?
    let addressLine2: String?
    let city, state: String?
    let defaultAddress: Int?
    let shippingBillingAddress, addressInstructions, lat, lng: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case addressRef = "address_ref"
        case makaniNumber = "makani_number"
        case location, apartment, name, email
        case mobileNumber = "mobile_number"
        case pincode
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city, state
        case defaultAddress = "default_address"
        case shippingBillingAddress = "shipping_billing_address"
        case addressInstructions = "address_instructions"
        case lat, lng
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
