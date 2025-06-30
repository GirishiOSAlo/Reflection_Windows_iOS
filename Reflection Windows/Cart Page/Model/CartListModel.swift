//
//  CartListModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 11/03/24.
//

import Foundation

//// MARK: - Welcome
//struct CartListModel: Codable {
//    let data: CartListResult?
//    let success: Bool?
//    let message: String?
//    let statusCode: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case data, success, message
//        case statusCode = "status_code"
//    }
//}
//
//// MARK: - DataClass
//struct CartListResult: Codable {
//    let carts: [Cart]?
//    let carts1: [Carts1]?
//    let user: CartUser?
//    let subtotal: String?
//}
//
//// MARK: - Cart
//struct Cart: Codable {
//    let id, productID: Int?
//    let productName: String?
//    let userID: Int?
//    let storeID: Int?
//    let unitPriceExclVat, singleUnitPriceExclVat, vatRate: String?
//    let cartCount, isOffer, offerType: Int?
//    let offerRate: String?
//    let offerValue: Int?
//    let discountPrice: String?
//    let discountedQty, prescriptionOrderStatus, orderID: Int?
//    let product: CartProduct?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case productID = "product_id"
//        case productName = "product_name"
//        case userID = "user_id"
//        case storeID = "store_id"
//        case unitPriceExclVat = "unit_price_excl_vat"
//        case singleUnitPriceExclVat = "single_unit_price_excl_vat"
//        case vatRate = "vat_rate"
//        case cartCount = "cart_count"
//        case isOffer = "is_offer"
//        case offerType = "offer_type"
//        case offerRate = "offer_rate"
//        case offerValue = "offer_value"
//        case discountPrice = "discount_price"
//        case discountedQty = "discounted_qty"
//        case prescriptionOrderStatus = "prescription_order_status"
//        case orderID = "order_id"
//        case product
//    }
//}
//
//// MARK: - Carts1
//struct Carts1: Codable {
//    let id, productID: Int?
//    let productName: String?
//    let productImage: String?
//    let userID: Int?
//    let storeID: Int?
//    let width, height: Int?
//    let unitPriceExclVat, singleUnitPriceExclVat: String?
//    let cartCount: Int?
//    let customizer: [Customizer]?
//    let finalprice: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case productID = "product_id"
//        case productName = "product_name"
//        case productImage = "product_image"
//        case userID = "user_id"
//        case storeID = "store_id"
//        case width, height
//        case unitPriceExclVat = "unit_price_excl_vat"
//        case singleUnitPriceExclVat = "single_unit_price_excl_vat"
//        case cartCount = "cart_count"
//        case customizer, finalprice
//    }
//}
//
//// MARK: - Product
//struct CartProduct: Codable {
//    let id: Int?
//    let productName, productID: String?
//    let quantity: Int?
//    let price, barcode, countryOfOrigin, vatRate: String?
//    let brandName: String?
//    let categoryID, subCategoryID: Int?
//    let unit, manufacturedBy: String?
//    let description: String?
//    let benefits, activeIngredients, deletedAt: String?
//    let productImage: String?
//    let productImgStatus: Int?
//    let longDescription: String?
//    let status: Int?
//    let categories: Categories?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case productName = "product_name"
//        case productID = "productId"
//        case quantity, price, barcode
//        case countryOfOrigin = "country_of_origin"
//        case vatRate = "vat_rate"
//        case brandName = "brand_name"
//        case categoryID = "category_id"
//        case subCategoryID = "sub_category_id"
//        case unit
//        case manufacturedBy = "manufactured_by"
//        case description, benefits
//        case activeIngredients = "active_ingredients"
//        case deletedAt = "deleted_at"
//        case productImage = "product_image"
//        case productImgStatus = "product_img_status"
//        case longDescription = "long_description"
//        case status, categories
//    }
//}
//
//// MARK: - Categories
//struct Categories: Codable {
//    let id: Int?
//    let categoriesName: String?
//    let categoriesImage: String?
//    let categoriesColor, shortDescription, productFeatures, description: String?
//    let deletedAt: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case categoriesName = "categories_name"
//        case categoriesImage = "categories_image"
//        case categoriesColor = "categories_color"
//        case shortDescription = "short_description"
//        case productFeatures = "product_features"
//        case description
//        case deletedAt = "deleted_at"
//    }
//}
//
//// MARK: - User
//struct CartUser: Codable {
//    let id: Int?
//    let fullname, avatar: String?
//    let countryCode: String?
//    let mobile: String?
//    let deviceToken: String?
//    let email, dob, empID: String?
//    let gender, nationality, emiratesID, healthCard: String?
//    let citizenshipCard: String?
//    let driverLicenseNum: String?
//    let emailVerifiedAt: String?
//    let otp: Int?
//    let otpExpireTime: String?
//    let address, city, state, postalCode: String?
//    let lat, lng: String?
//    let fid, gid: Int?
//    let isStoppedRequest, isFbSignup, isGmailSignup, isManualSignup: Int?
//    let storeID: Int?
//    let employeeStatusID: Int?
//    let signupPlatform: Int?
//    let uniqueNo, deviceType: Int?
//    let orderUpdatesNoti, promotionsDealNoti, newProductsNoti, deliveryInstallationNoti: Int?
//    let customerReviewRatingNoti: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, fullname, avatar
//        case countryCode = "country_code"
//        case mobile
//        case deviceToken = "device_token"
//        case email, dob
//        case empID = "empId"
//        case gender, nationality
//        case emiratesID = "emirates_id"
//        case healthCard = "health_card"
//        case citizenshipCard = "citizenship_card"
//        case driverLicenseNum = "driver_license_num"
//        case emailVerifiedAt = "email_verified_at"
//        case otp
//        case otpExpireTime = "otp_expire_time"
//        case address, city, state
//        case postalCode = "postal_code"
//        case lat, lng, fid, gid, isStoppedRequest
//        case isFbSignup = "is_fb_signup"
//        case isGmailSignup = "is_gmail_signup"
//        case isManualSignup = "is_manual_signup"
//        case storeID = "store_id"
//        case employeeStatusID = "employee_status_id"
//        case signupPlatform = "signup_platform"
//        case uniqueNo = "unique_no"
//        case deviceType = "device_type"
//        case orderUpdatesNoti = "order_updates_noti"
//        case promotionsDealNoti = "promotions_deal_noti"
//        case newProductsNoti = "new_products_noti"
//        case deliveryInstallationNoti = "delivery_installation_noti"
//        case customerReviewRatingNoti = "customer_review_rating_noti"
//    }
//}
//
// MARK: - Welcome
struct CartListModel: Codable {
    let data: CartListResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct CartListResult: Codable {
    let carts: [Cart]?
    let user: CartUser?
    let subtotal: String?
}

// MARK: - Cart
struct Cart: Codable {
    var id, productID: Int?
    var productName: String?
    var productImage: String?
    var categoryName: String?
    var categoryID, userID: Int?
    var storeID: Int?
    var width, height: String?
    var isSwing, leftSwing, rightSwing: Int?
    var unitPriceExclVat, singleUnitPriceExclVat: String?
    var productPrice: String?
    var cartCount: Int?
    let insectMesh: Bool?
    var customizer: [Customizer]?
    var finalprice: String?


    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case productName = "product_name"
        case productImage = "product_image"
        case categoryID = "category_id"
        case categoryName = "category_name"
        case userID = "user_id"
        case storeID = "store_id"
        case width, height
        case isSwing = "is_swing"
        case leftSwing = "left_swing"
        case rightSwing = "right_swing"
        case unitPriceExclVat = "unit_price_excl_vat"
        case singleUnitPriceExclVat = "single_unit_price_excl_vat"
        case productPrice = "product_price"
        case cartCount = "cart_count"
        case insectMesh = "insect_mesh"
        case customizer, finalprice
    }
}

// MARK: - Customizer
struct Customizer: Codable {
    let id, customizerID: Int?
    let name, type: String?
    let options: [CartSubOption]?
    let unitPrice, customizerPrice, optionsPrice, price: String?
    let colorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case customizerID = "customizer_id"
        case name, type, options
        case unitPrice = "unit_price"
        case customizerPrice = "customizer_price"
        case optionsPrice = "options_price"
        case price
        case colorCode = "color_code"
    }
}

// MARK: - Option
struct CartSubOption: Codable {
    let id, optionID: Int
    let name, unitPrice, price: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case optionID = "option_id"
        case name
        case unitPrice = "unit_price"
        case price
    }
}

// MARK: - User
struct CartUser: Codable {
    let id: Int?
    let fullname, avatar, countryCode, mobile: String?
    let deviceToken: String?
    let email, dob, empID, gender: String?
    let nationality, emiratesID: String?
    let healthCard, citizenshipCard: String?
    let driverLicenseNum, emailVerifiedAt: String?
    let otp: Int?
    let otpExpireTime: String?
    let address, city, state, postalCode: String?
    let lat, lng: String?
    let fid, gid: String?
    let isStoppedRequest, isFbSignup, isGmailSignup, isManualSignup: Int?
    let storeID, employeeStatusID: Int?
    let signupPlatform, uniqueNo: Int?
    let deviceType: Int?
    let orderUpdatesNoti, promotionsDealNoti, newProductsNoti, deliveryInstallationNoti: Int?
    let customerReviewRatingNoti: Int?

    enum CodingKeys: String, CodingKey {
        case id, fullname, avatar
        case countryCode = "country_code"
        case mobile
        case deviceToken = "device_token"
        case email, dob
        case empID = "empId"
        case gender, nationality
        case emiratesID = "emirates_id"
        case healthCard = "health_card"
        case citizenshipCard = "citizenship_card"
        case driverLicenseNum = "driver_license_num"
        case emailVerifiedAt = "email_verified_at"
        case otp
        case otpExpireTime = "otp_expire_time"
        case address, city, state
        case postalCode = "postal_code"
        case lat, lng, fid, gid, isStoppedRequest
        case isFbSignup = "is_fb_signup"
        case isGmailSignup = "is_gmail_signup"
        case isManualSignup = "is_manual_signup"
        case storeID = "store_id"
        case employeeStatusID = "employee_status_id"
        case signupPlatform = "signup_platform"
        case uniqueNo = "unique_no"
        case deviceType = "device_type"
        case orderUpdatesNoti = "order_updates_noti"
        case promotionsDealNoti = "promotions_deal_noti"
        case newProductsNoti = "new_products_noti"
        case deliveryInstallationNoti = "delivery_installation_noti"
        case customerReviewRatingNoti = "customer_review_rating_noti"
    }
}
