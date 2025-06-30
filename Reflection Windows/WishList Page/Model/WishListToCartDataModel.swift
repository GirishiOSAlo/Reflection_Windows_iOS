//
//  WishListToCartDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 29/03/24.
//

import Foundation
// MARK: - Welcome
struct WishListToCartDataModel: Codable {
    let data: WishListToCartResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct WishListToCartResult: Codable {
    let userCarts: [WishListToCartUserCart]?
    let userCartProductCount: Int?

    enum CodingKeys: String, CodingKey {
        case userCarts
        case userCartProductCount = "user_cart_product_count"
    }
}

// MARK: - UserCart
struct WishListToCartUserCart: Codable {
    let productID, categoryID, userID: Int?
    let storeID: Int?
    let width, height, productName, unitPriceExclVat: String?
    let singleUnitPriceExclVat: String?
    let vatRate: Double?
    let cartCount, isOffer, offerType, offerValue: Int?
    let offerRate, discountedQty, discountPrice, id: Int?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case categoryID = "category_id"
        case userID = "user_id"
        case storeID = "store_id"
        case width, height
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
