//
//  BillingSummaryDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 14/03/24.
//

import Foundation

// MARK: - Welcome
struct BillingSummaryDataModel: Codable {
    let data: BillingSummaryResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct BillingSummaryResult: Codable {
    let carts: [BillingSummaryCart]?
    let subtotal, loyalty: String?
    let shipping: String?
    let salestax, salestaxPercent, extendedWarrenty, total, totalExtendedWarrenty: String?
    let estimatedate: String?

    enum CodingKeys: String, CodingKey {
        case carts, subtotal, loyalty, shipping, salestax
        case salestaxPercent = "salestax_percent"
        case extendedWarrenty = "extended_warrenty"
        case total
        case totalExtendedWarrenty = "total_extended_warrenty"
        case estimatedate
    }
}

// MARK: - Cart
struct BillingSummaryCart: Codable {
    let id, productID: Int?
    let productName: String?
    let productImage: String?
    let categoryName: String?
    let categoryID, userID: Int?
    let storeID: Int?
    let width, height: String?
    let isSwing, leftSwing, rightSwing: Int?
    let unitPriceExclVat, singleUnitPriceExclVat, productPrice: String?
    let cartCount: Int?
    let insectMesh: Bool?
    //let volume: Int?
    let customizer: [BillingSummaryCustomizer]?
    let finalprice: String?
    
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
        //case volume
        case customizer, finalprice
    }
}

// MARK: - Customizer
struct BillingSummaryCustomizer: Codable {
    let id, customizerID: Int?
    let name, type: String?
    let options: [BillingSummaryOption]?
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
struct BillingSummaryOption: Codable {
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

//
//// MARK: - Welcome
//struct BillingSummaryDataModel: Codable {
//    let data: BillingSummaryResult?
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
//struct BillingSummaryResult: Codable {
//    let carts: [BillingSummaryCart]?
//    let subtotal, loyalty: String?
//    let shipping: Int?
//    let salestax, extendedWarrenty, total, totalExtendedWarrenty: String?
//    let estimatedate: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case carts, subtotal, loyalty, shipping, salestax
//        case extendedWarrenty = "extended_warrenty"
//        case total
//        case totalExtendedWarrenty = "total_extended_warrenty"
//        case estimatedate
//    }
//}
//
//// MARK: - Cart
//struct BillingSummaryCart: Codable {
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
//    let product: BillingSummaryProduct?
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
//// MARK: - Product
//struct BillingSummaryProduct: Codable {
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
//    let categories: BillingSummaryCategories?
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
//struct BillingSummaryCategories: Codable {
//    let id: Int?
//    let categoriesName: String?
//    let categoriesImage, categoriesThumbnail: String?
//    let categoriesColor, shortDescription, description: String?
//    let deletedAt: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case categoriesName = "categories_name"
//        case categoriesImage = "categories_image"
//        case categoriesThumbnail = "categories_thumbnail"
//        case categoriesColor = "categories_color"
//        case shortDescription = "short_description"
//        case description
//        case deletedAt = "deleted_at"
//    }
//}
//
//// MARK: - User
//struct BillingSummaryUser: Codable {
//    let id: Int?
//    let fullname, avatar, countryCode, mobile: String?
//    let deviceToken: String?
//    let email, dob, empID, gender: String?
//    let nationality, emiratesID: String?
//    let healthCard, citizenshipCard: String?
//    let driverLicenseNum, emailVerifiedAt: String?
//    let otp: Int?
//    let otpExpireTime: String?
//    let address, city, state, postalCode: String?
//    let lat, lng: String?
//    let fid, gid: String?
//    let isStoppedRequest, isFbSignup, isGmailSignup, isManualSignup, storeID: Int?
//    let employeeStatusID: String?
//    let signupPlatform, uniqueNo: Int?
//    let deviceType: String?
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
