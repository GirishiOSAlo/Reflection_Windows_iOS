//
//  WishListDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/03/24.
//

import Foundation

// MARK: - Welcome
struct WishListDataModel: Codable {
    let data: WishListDataResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct WishListDataResult: Codable {
    let wishlist: [WishlistData]?
}

// MARK: - Wishlist
struct WishlistData: Codable {
    let id, productID: Int?
    let productName: String?
    let productImage: String?
    let categoriesID: Int?
    let categoriesName: String?
    let userID: Int?
    let storeID: Int?
    let width, height: String?
    let isSwing, leftSwing, rightSwing: Int?
    let unitPriceExclVat, singleUnitPriceExclVat: String?
    let reviewCount, cartCount: Int?
    let customizer: [WishlistCustomizer]?
    let finalprice: String?

    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case productName = "product_name"
        case productImage = "product_image"
        case categoriesID = "categories_id"
        case categoriesName = "categories_name"
        case userID = "user_id"
        case storeID = "store_id"
        case width, height
        case isSwing = "is_swing"
        case leftSwing = "left_swing"
        case rightSwing = "right_swing"
        case unitPriceExclVat = "unit_price_excl_vat"
        case singleUnitPriceExclVat = "single_unit_price_excl_vat"
        case reviewCount = "review_count"
        case cartCount = "cart_count"
        case customizer, finalprice
    }
}

// MARK: - Customizer
struct WishlistCustomizer: Codable {
    let id, customizerID: Int?
    let name: String?
    let options: [WishlistOption]?
    let unitPrice, customizerPrice, optionsPrice, price: String?
    let colorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case customizerID = "customizer_id"
        case name, options
        case unitPrice = "unit_price"
        case customizerPrice = "customizer_price"
        case optionsPrice = "options_price"
        case price
        case colorCode = "color_code"
    }
}

// MARK: - Option
struct WishlistOption: Codable {
    let id, optionID: Int?
    let name, unitPrice, price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case optionID = "option_id"
        case name
        case unitPrice = "unit_price"
        case price
    }
}
