//
//  GuestLoginDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/03/24.
//

import Foundation

// MARK: - Welcome
struct GuestLoginDataModel: Codable {
    let data: GuestLoginDataResult?
    let success: Bool?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct GuestLoginDataResult: Codable {
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
    let signupPlatform: Int?
    let uniqueNo, deviceType: Int?
    let tokenId, token: String?
    let storeInRange: [StoreInRange]?

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
        case tokenId = "token_id"
        case token, storeInRange
    }
}

// MARK: - StoreInRange
struct StoreInRange: Codable {
    let id: Int?
    let storeName, lat, lng, address: String?
    let storeContact, storeEmail, storeWorkingHours: String?
    let orderSlotThreshold: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case storeName = "store_name"
        case lat, lng, address
        case storeContact = "store_contact"
        case storeEmail = "store_email"
        case storeWorkingHours = "store_working_hours"
        case orderSlotThreshold = "order_slot_threshold"
    }
}
