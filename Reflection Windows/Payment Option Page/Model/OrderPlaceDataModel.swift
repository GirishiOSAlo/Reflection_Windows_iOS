//
//  OrderPlaceDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 01/04/24.
//

import Foundation

// MARK: - Welcome
struct OrderPlaceDataModel: Codable {
    let data: OrderPlaceResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct OrderPlaceResult: Codable {
    let shippingAddressID, billingAddressID, userID: Int?
    let orderID, quantity: String?
    let orderTypes: Int?
    let orderAmount, orderItemAmount: String?
    let orderCustomizationAmount: String?
    let totalAmountExclVat, totalVatAmount: String?
    let paymentID: Int?
    let shippingCharges: String?
    let estimatedDelivery, createdAt: String?
    let id: Int?
    let updatedStatus: String?
//    let store: [JSONNull?]?
    let product: [OrderPlaceProductElement]?
//    let orderStatusCatalog: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case shippingAddressID = "shipping_address_id"
        case billingAddressID = "billing_address_id"
        case userID = "user_id"
        case orderID = "orderId"
        case quantity
        case orderTypes = "order_types"
        case orderAmount = "order_amount"
        case orderItemAmount = "order_item_amount"
        case orderCustomizationAmount = "order_customization_amount"
        case totalAmountExclVat = "total_amount_excl_vat"
        case totalVatAmount = "total_vat_amount"
        case paymentID = "payment_id"
        case shippingCharges = "shipping_charges"
        case estimatedDelivery = "estimated_delivery"
        case createdAt = "created_at"
        case id
        case updatedStatus = "updated_status"
//        case store
        case product
//        case orderStatusCatalog
    }
}

// MARK: - ProductElement
struct OrderPlaceProductElement: Codable {
    let id, orderID, productID: Int?
    let productName: String?
    let width, height: String?
    let unitPrice, singleUnitPrice: String?
    let returnRequest: Int?
    let returnReason: String?
    let replaceProduct: Int?
    let replaceReason: String?
    let quantity: Int?
    let totalPrice: String?
    let isOffer, offerType, offerValue: Int?
    let offerRate, discountPrice: String?
    let discountedQty: Int?
    let vatRate: String?
    let productPicked: Int?
    let pickStatus, editReason, deletedAt: String?
    let product: OrderPlaceProductProduct?

    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case productID = "product_id"
        case productName = "product_name"
        case width, height
        case unitPrice = "unit_price"
        case singleUnitPrice = "single_unit_price"
        case returnRequest = "return_request"
        case returnReason = "return_reason"
        case replaceProduct = "replace_product"
        case replaceReason = "replace_reason"
        case quantity
        case totalPrice = "total_price"
        case isOffer = "is_offer"
        case offerType = "offer_type"
        case offerValue = "offer_value"
        case offerRate = "offer_rate"
        case discountPrice = "discount_price"
        case discountedQty = "discounted_qty"
        case vatRate = "vat_rate"
        case productPicked = "product_picked"
        case pickStatus = "pick_status"
        case editReason = "edit_reason"
        case deletedAt = "deleted_at"
        case product
    }
}

// MARK: - ProductProduct
struct OrderPlaceProductProduct: Codable {
    let id: Int?
    let productName, productID: String?
    let quantity: Int?
    let price, barcode, countryOfOrigin, vatRate: String?
    let brandName: String?
    let categoryID, subCategoryID: Int?
    let unit, manufacturedBy: String?
    let description: String?
    let benefits, activeIngredients, deletedAt: String?
    let productImage: String?
    let productImgStatus: Int?
    let longDescription: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case productName = "product_name"
        case productID = "productId"
        case quantity, price, barcode
        case countryOfOrigin = "country_of_origin"
        case vatRate = "vat_rate"
        case brandName = "brand_name"
        case categoryID = "category_id"
        case subCategoryID = "sub_category_id"
        case unit
        case manufacturedBy = "manufactured_by"
        case description, benefits
        case activeIngredients = "active_ingredients"
        case deletedAt = "deleted_at"
        case productImage = "product_image"
        case productImgStatus = "product_img_status"
        case longDescription = "long_description"
        case status
    }
}


