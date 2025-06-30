//
//  OrderSummaryDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 01/04/24.
//

import Foundation

// MARK: - Welcome
struct OrderSummaryDataModel: Codable {
    let data: OrderSummaryResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct OrderSummaryResult: Codable {
    let order: OrderSummaryOrder?
}

// MARK: - Order
struct OrderSummaryOrder: Codable {
    let estimatedDelivery: String?
    let products: [OrderSummaryProduct]?
    let salestax, salestaxPercent: String?
    let orderDate, orderNo, orderTotal, paymentItems: String?
    let paymentMode, paymentCustomization, paymentShippingCharges: String?
    let shippingAddress: OrderSummaryShippingAddress?
    var submittalsURL: String?

    enum CodingKeys: String, CodingKey {
        case estimatedDelivery = "estimated_delivery"
        case salestax
        case salestaxPercent = "salestax_percent"
        case products
        case orderDate = "order_date"
        case orderNo = "order_no"
        case orderTotal = "order_total"
        case paymentItems = "payment_items"
        case paymentMode = "payment_mode"
        case paymentCustomization = "payment_customization"
        case paymentShippingCharges = "payment_shipping_charges"
        case shippingAddress = "shipping_address"
        case submittalsURL = "submittals_url"
    }
}

// MARK: - Product
struct OrderSummaryProduct: Codable {
    let productID, orderDetailID: Int?
    let productName: String?
    let leftSwing, rightSwing: Int?
    let glass, glassOptions, anchorage, color: String?
    let productImage: String?
    let width, height, totalPrice: String?
    let cartCount: Int?
    let category: String?
    let ratings: Int?
    let insectMesh: Bool?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case orderDetailID = "order_detail_id"
        case productName = "product_name"
        case leftSwing = "left_swing"
        case rightSwing = "right_swing"
        case glass
        case glassOptions = "glass_options"
        case anchorage, color
        case productImage = "product_image"
        case width, height
        case totalPrice = "total_price"
        case cartCount = "cart_count"
        case category, ratings
        case insectMesh = "insect_mesh"
    }
}

// MARK: - ShippingAddress
struct OrderSummaryShippingAddress: Codable {
    let id: Int?
    let name, mobileNumber, addressLine1, addressLine2: String?
    let city, state, pincode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case mobileNumber = "mobile_number"
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city, state, pincode
    }
}
