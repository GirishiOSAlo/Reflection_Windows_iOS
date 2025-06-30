//
//  PreOrderDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 02/04/24.
//

import Foundation

// MARK: - Welcome
struct PreOrderDataModel: Codable {
    let data: PreOrderDataResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct PreOrderDataResult: Codable {
    let currentPage, lastPage: Int?
    let data: [PreOrderData]?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case data
    }
}

// MARK: - Datum
struct PreOrderData: Codable {
    let id: Int?
    let orderDate, orderNo, orderTotal: String?
    let quantity: Int?
    let paymentItems, paymentMode, paymentCustomization, paymentShippingCharges: String?
    let estimatedDelivery: String?
    let products: [PreOrderProduct]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderDate = "order_date"
        case orderNo = "order_no"
        case orderTotal = "order_total"
        case quantity
        case paymentItems = "payment_items"
        case paymentMode = "payment_mode"
        case paymentCustomization = "payment_customization"
        case paymentShippingCharges = "payment_shipping_charges"
        case estimatedDelivery = "estimated_delivery"
        case products, status
    }
}

// MARK: - Product
struct PreOrderProduct: Codable {
    let orderDetailID, productID: Int?
    let productName, color: String?
    let productImage: String?
    let width, height: String?
    let totalPrice: String?
    let cartCount, rating: Int?
    let category: String?
    let insectMesh: Bool?

    enum CodingKeys: String, CodingKey {
        case orderDetailID = "order_detail_id"
        case productID = "product_id"
        case productName = "product_name"
        case color
        case productImage = "product_image"
        case width, height
        case totalPrice = "total_price"
        case cartCount = "cart_count"
        case rating, category
        case insectMesh = "insect_mesh"
    }
}
