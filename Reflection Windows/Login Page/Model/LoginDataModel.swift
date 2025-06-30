//
//  LoginDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 07/03/24.
//

import Foundation

class LoginDataModel: Codable {
    let data: LoginDataResult?
    let success: Bool?
    let statusCode: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct LoginDataResult: Codable {
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
    let storeID: Int?
    let employeeStatusID: String?
    let signupPlatform, uniqueNo: Int?
    let deviceType: Int?
    let token: String?

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
        case token
    }
}
