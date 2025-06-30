//
//  GeneratePayPalTokenModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 26/04/24.
//

import Foundation
// MARK: - Welcome
struct GeneratePayPalTokenModel: Codable {
    var scope: String?
    var accessToken, tokenType, appID: String?
    var expiresIn: Int?
    var nonce: String?

    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case appID = "app_id"
        case expiresIn = "expires_in"
        case nonce
    }
}


// MARK: - Welcome
struct GeneratePayPalOrderId: Codable {
    var id, status: String?
    var links: [PayPalOrderIdLink]?
}

// MARK: - Link
struct PayPalOrderIdLink: Codable {
    var href: String?
    var rel, method: String?
}
