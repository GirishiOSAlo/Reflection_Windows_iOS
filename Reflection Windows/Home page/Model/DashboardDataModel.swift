//
//  DashboardDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/03/24.
//

import Foundation

// MARK: - Welcome
struct DashboardDataModel: Codable {
    let data: DashboardDataResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct DashboardDataResult: Codable {
    let user: DashboardUserDetails?
    let collections: [DashboardCollection]?
    let resources: [DashboardResource]?
    var carts, wishlist: Int?
}

// MARK: - Collection
struct DashboardCollection: Codable {
    let id: Int?
    let categoriesName: String?
    let categoriesImage, categoriesThumbnail, frontimage: String?
    let categoriesColor, shortDescription, description: String?
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case categoriesName = "categories_name"
        case categoriesImage = "categories_image"
        case categoriesThumbnail = "categories_thumbnail"
        case frontimage
        case categoriesColor = "categories_color"
        case shortDescription = "short_description"
        case description
        case deletedAt = "deleted_at"
    }
}

// MARK: - Resource
struct DashboardResource: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let url: String?
    let resourcesCategoryID: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, url
        case resourcesCategoryID = "resources_category_id"
    }
}

// MARK: - User
struct DashboardUserDetails: Codable {
    let id: Int?
    let fullname, avatar: String?
    let countryCode: String?
    let mobile: String?
    let deviceToken: String?
    let email, dob, empID: String?
    let gender, nationality, emiratesID, healthCard: String?
    let citizenshipCard: String?
    let driverLicenseNum: String?
    let emailVerifiedAt: String?
    let otp: Int?
    let otpExpireTime: String?
    let address, city, state, postalCode: String?
    let lat, lng: String?
    let fid, gid: String?
    let isStoppedRequest, isFbSignup, isGmailSignup, isManualSignup: Int?
    let storeID: Int?
    let employeeStatusID: String?
    let signupPlatform, uniqueNo: Int?
    let deviceType: Int?

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
    }
}
