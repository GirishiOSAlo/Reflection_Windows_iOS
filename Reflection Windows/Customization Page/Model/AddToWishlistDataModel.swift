//
//  AddToWishlistDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/03/24.
//

import Foundation

// MARK: - Welcome
struct AddToWishlistDataModel: Codable {
    let data: AddToWishlistResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct AddToWishlistResult: Codable {
    let wishlist: [WishlistProduct]?
    let userWishlistProductCount: Int?

    enum CodingKeys: String, CodingKey {
        case wishlist
        case userWishlistProductCount = "user_wishlist_product_count"
    }
}

// MARK: - Wishlist
struct WishlistProduct: Codable {
    let productID, userID: Int?
    let storeID: Int?
    let width, height: String?
    let productName: String?
    let unitPriceExclVat: String?
    let singleUnitPriceExclVat: String?
    let vatRate: Double?
    let cartCount, isOffer, offerType: Int?
    let offerValue, offerRate, discountedQty, discountPrice: Int?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
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
