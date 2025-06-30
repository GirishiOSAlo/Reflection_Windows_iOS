//
//  AddToCartDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 11/03/24.
//

import Foundation

// MARK: - Welcome
struct AddToCartDataModel: Codable {
//    let data: AddToCartResult?
    var data: DataClass?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct DataClass: Codable {
}

// MARK: - DataClass
struct AddToCartResult: Codable {
    let userCarts: [AddToUserCarts]?
    let userCartProductCount: Int?

    enum CodingKeys: String, CodingKey {
        case userCarts
        case userCartProductCount = "user_cart_product_count"
    }
}

// MARK: - UserCarts
struct AddToUserCarts: Codable {
    let productID, userID: Int?
    let storeID, productName: String?
    let unitPriceExclVat: String?
    let singleUnitPriceExclVat: String?
    let vatRate: Double?
    let cartCount, isOffer, offerType, offerValue: Int?
    let offerRate, discountedQty, discountPrice, id: Int?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case userID = "user_id"
        case storeID = "store_id"
        case productName = "product_name"
        case unitPriceExclVat = "unit_price_excl_vat"
        case singleUnitPriceExclVat = "single_unit_price_excl_vat"
        case vatRate = "vat_rate"
        case cartCount = "cart_count"
        case isOffer = "is_offer"
        case offerType = "offer_type"
        case offerValue = "offer_value"
        case offerRate = "offer_rate"
        case discountedQty = "discounted_qty"
        case discountPrice = "discount_price"
        case id
    }
}
