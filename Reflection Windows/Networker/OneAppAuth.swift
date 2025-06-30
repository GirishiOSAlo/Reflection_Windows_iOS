//
//  OneAppAuth.swift
//  NetWorker
//
//  Created by Chaitanya Soni on 05/02/21.
//  Copyright © 2021 Chaitanya Soni. All rights reserved.
//

import Foundation

public enum AuthCustom {
    
    case login(email: String, password: String, guest_session_id: String)
    case signUp(email: String, password: String, deviceToken: String, guest_session_id: String)
    case sendOTP(email: String, requestPlace: String)
    case verifyOTP(email: String, otp: String, noRegister: Int)
    case resetPassword(password: String, cpassword: String, email: String, unique_id: String)
    case guestLogin
    case dashboard
    case resources
//    case addToCart(product_id: Int, dimension: [DimensionData], customizer: [Int])
    case cartData
    case deleteCart(cart_id: [Int])
    case addressList(type: String)
    case addNewAddress(name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String)
    case deleteAddress(type:String, customer_address_id:Int)
    
    case productList(category_id: Int, cart_id:String)
    case shippingOption(customer_address_id: Int)
    case billingSummaryData(shipping_option_id: Int, shipping_address_id: Int)
    case logout
    case updateProfile(fullname:String, mobile:String, email:String, dob:String)
    case changeProfileImage(avatar_img: String)
    case notificationSetting(order_updates_noti:Int, promotions_deal_noti:Int, new_products_noti:Int, delivery_installation_noti:Int, customer_review_rating_noti:Int, noti:String)
    case profile
    case changePassword(old_password: String, password: String, confirm_password: String)
    case wishlist
    case deleteWishlist(wishlist_id:[Int])
    case wishlistToCart(wishlist_id: Int)
    case placeOrder(shipping_address_id: Int, shipping_option_id: Int, billing_address_id: Int, paymentMethod: String, extended_warrenty: Int, nonce: String, payment_platform: String)
    case orderSummaryData(id: Int)
    case prevOrder(page:Int, status:String, time:Int, search:String, limit:Int)
    case prevOrderDetails(id:Int)
    case productRating(order_id: Int, order_detail_id: Int, product_id: Int, rating: Int)
    case cartDataUpdate(cart_count:Int)
    case editAddress(id: Int,name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String)
    case zipcallus(zipcode: String)
    case faq
}

enum Swiftie: AppAuth {
    
    case swiftieAuthenticateUser(email: String, phone: String, returnURL: String, serviceType: String, TID: String)
}

extension Swiftie {
    
    var encryptionType: EncryptionType {
        return .AES
    }
    
    var isRequestEncrypted: Bool {
        return true
    }
    
    var baseURL: URL {
        URL(string: "https://swiftie.net/")!
    }
    
    var path: String {
        switch self {
        case .swiftieAuthenticateUser:
            return "ExternalMicroservice/api/Account/AuthenticateUser"
        }
    }
    
    var fullURL: URL {
        return URL(string: baseURL.absoluteString + path)!
    }
    
    var method: String { return "POST" }
    
    var sampleData: Data { return Data() }
    
    var params: [String : Any] {
        var params: [String : Any] = [:]
        switch self {
        
        case .swiftieAuthenticateUser(email: let email, phone: let phone, returnURL: let returnURL, serviceType: let serviceType, TID: let TID):
            params = ["Email": email,"Phone": phone,"ReturnUrl": returnURL,"ServiceType": serviceType, "TID": TID]
        }
        return params
    }
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers = ["Content-Type" : "application/json"]
        return headers
    }
}

protocol AppAuth {
    var encryptionType: EncryptionType { get }
    
    var isRequestEncrypted: Bool { get }
    var baseURL: URL { get }
    var path: String { get }
    var fullURL: URL { get }
    var method: String { get }
    var sampleData: Data { get }
    var params: [String : Any] { get }
    var headers: [String : String]? { get }
}

enum EncryptionType {
    case AES
    case RSA_AES
}

enum OneAppAuth: AppAuth {
    
//login API request
    case login(email: String, password: String, guest_session_id: String)
    case signUp(email: String, password: String, deviceToken: String, guest_session_id:String)
    case sendOTP(email: String, requestPlace: String)
    case verifyOTP(email: String, otp: String, noRegister: Int)
    case resetPassword(password: String, cpassword: String, email: String, unique_id: String)
    case guestLogin
    case dashboard
    case resources
//    case addToCart(product_id: Int, dimension: CartDimensionArr, customizer: [Int])
    case cartData
    case deleteCart(cart_id: [Int])
    case addressList(type: String)
    case addNewAddress(name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String)
    case deleteAddress(type:String, customer_address_id:Int)
    
    case productList(category_id: Int, cart_id:String)
    case shippingOption(customer_address_id: Int)
    case billingSummaryData(shipping_option_id: Int, shipping_address_id: Int)
    case logout
    case updateProfile(fullname:String, mobile:String, email:String, dob:String)
    case changeProfileImage(avatar_img: String)
    case notificationSetting(order_updates_noti:Int, promotions_deal_noti:Int, new_products_noti:Int, delivery_installation_noti:Int, customer_review_rating_noti:Int, noti:String)
    case profile
    case changePassword(old_password: String, password: String, confirm_password: String)
    case wishlist
    case deleteWishlist(wishlist_id:[Int])
    case wishlistToCart(wishlist_id: Int)
    case placeOrder(shipping_address_id: Int, shipping_option_id: Int, billing_address_id: Int, paymentMethod: String, extended_warrenty: Int, nonce: String, payment_platform: String)
    case orderSummaryData(id: Int)
    case prevOrder(page:Int, status:String, time:Int, search:String, limit:Int)
    case prevOrderDetails(id:Int)
    case productRating(order_id: Int, order_detail_id: Int, product_id: Int, rating: Int)
    case cartDataUpdate(cart_count:Int)
    case editAddress(id: Int,name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String)
    case zipcallus(zipcode: String)
    case faq
}

extension OneAppAuth {
    
    var encryptionType: EncryptionType {
        return .RSA_AES
    }

	var isRequestEncrypted: Bool {
		switch self {
        default:
			return true
		}
	}
}

extension OneAppAuth {
	var baseURL: URL {
        switch self {
//        case .createTicketFreshDesk, .freshDeskFolders, .deleteTickets:
//            return URL(string: "https://divine-talk.freshdesk.com/api/")! //freshDesk API
//        case .freshDeskChatReply:
//            return URL(string: "https://divine-talk.freshdesk.com/api/tickets/\(userDefaults.ticketId)/")!
    
        default:
            //return URL(string: "https://reflection-window.loca.lt/reflection-window/public/api/")! //UAT
            return URL(string: Constants.baseProductionURL)!
        }
	}
	
	var path: String {
		switch self {
        //login API request
        case .login:
            return "login"
        case .signUp:
            return "signup"
        case .sendOTP:
            return "sendOtp"
        case .verifyOTP:
            return "verifyOtp"
        case .resetPassword:
            return "password_reset"
        case .guestLogin:
            return "guestLogin"
        case .dashboard:
            return "dashboard"
        case .resources:
            return "resources"
//        case .addToCart:
//            return "addToCart"
        case .cartData:
            return "cartData"
        case .deleteCart:
            return "deleteCart"
        case .addressList:
            return "address"
        case .addNewAddress:
            return "addAddress"
        case .deleteAddress:
            return "deleteCustomerAddress"
            
        case .productList:
            return "productList"
        case .shippingOption:
            return "shippingoptions"
        case .billingSummaryData:
            return "billingSummaryData"
        case .logout:
            return "logout"
        case .updateProfile:
            return "updateProfile"
        case .notificationSetting:
            return "updateProfile"
        case .changeProfileImage:
            return "updateProfile"
        case .profile:
            return "profile"
        case .changePassword:
            return "changePassword"
        case .wishlist:
            return "wishlistData"
        case .deleteWishlist:
            return "deleteWishlist"
        case .wishlistToCart:
            return "wishlistToCart"
        case .placeOrder:
            return "placeOrder"
        case .orderSummaryData:
            return "orderSummaryData"
        case .prevOrder:
            return "prevOrder"
        case .prevOrderDetails:
            return "orderDetailData"
        case .productRating:
            return "rateOrder"
        case .cartDataUpdate:
            return "cartDataUpdate?id=\(userDefaults.cartUpdateProductID)"
        case .editAddress:
            return "editAddress"
        case .zipcallus:
            return "zipcallus"
        case .faq:
            return "getFaqs"
        }
	}
	
	var fullURL: URL {
		return URL(string: baseURL.absoluteString + path)!
	}
	
	var method: String {
		"POST"
	}
	
    var getMethod: String {
        "GET"
    }
    
	var sampleData: Data {
		Data()
	}
    
	var params: [String : Any] {
		var params: [String : Any] = [:]
        switch self {
            //login API request
        case .login(email: let email, password: let password, guest_session_id: let guest_session_id):
            params = ["email":email, "password":password, "guest_session_id":guest_session_id]
        case .signUp(email: let email, password: let password, deviceToken: let deviceToken, guest_session_id: let guest_session_id):
            params = ["email":email, "password":password, "device_token":deviceToken, "guest_session_id":guest_session_id]
        case .sendOTP(email: let email, requestPlace: let requestPlace):
            params = ["email":email, "request_place":requestPlace]
        case .verifyOTP(email: let email, otp: let otp, noRegister: let noRegister):
            params = ["email":email, "otp":otp, "noregister":noRegister]
        case .resetPassword(password: let password, cpassword: let cpassword, email: let email, unique_id: let unique_id):
            params = ["email":email, "password":password, "cpassword":cpassword, "unique_id":unique_id]
        case .guestLogin:
            break
        case .dashboard:
            break
        case .resources:
            break
            
//        case .addToCart(product_id: let product_id, dimension: let dimension, customizer: let customizer):
//            params = ["product_id":product_id, "dimension":dimension, "customizer":customizer]
        case .cartData:
            break
        case .deleteCart(cart_id: let cart_id):
            params = ["cart_id":cart_id]
        case .addressList(type: let type):
            params = ["type":type]
        case .addNewAddress(name: let name, email: let email, mobile_number: let mobile_number, pincode: let pincode, address_line_1: let address_line_1, address_line_2: let address_line_2, city: let city, state: let state, default_address: let default_address, shipping_billing_address: let shipping_billing_address):
            params = ["name":name, "email":email, "mobile_number":mobile_number, "pincode":pincode, "address_line_1":address_line_1, "address_line_2":address_line_2, "city":city, "state":state, "default_address":default_address, "shipping_billing_address":shipping_billing_address]
        case .deleteAddress(type: let type, customer_address_id: let customer_address_id):
            params = ["type":type, "customer_address_id":customer_address_id]
        case .productList(category_id: let category_id, cart_id: let cart_id):
            params = ["category_id":category_id, "cart_id":cart_id]
        case .shippingOption(customer_address_id: let customer_address_id):
            params = ["customer_address_id":customer_address_id]
        case .billingSummaryData(shipping_option_id: let shipping_option_id, shipping_address_id: let shipping_address_id):
            params = ["shipping_option_id":shipping_option_id, "shipping_address_id":shipping_address_id]
        case .logout:
            break
        case .updateProfile(fullname: let fullname, mobile: let mobile, email: let email, dob: let dob):
            params = ["fullname":fullname,"mobile":mobile,"email":email, "dob":dob]
        case .notificationSetting(order_updates_noti: let order_updates_noti, promotions_deal_noti: let promotions_deal_noti, new_products_noti: let new_products_noti, delivery_installation_noti: let delivery_installation_noti, customer_review_rating_noti: let customer_review_rating_noti, noti: let noti):
            params = ["order_updates_noti":order_updates_noti, "promotions_deal_noti":promotions_deal_noti, "new_products_noti":new_products_noti, "delivery_installation_noti":delivery_installation_noti, "customer_review_rating_noti":customer_review_rating_noti, "noti":noti]
        case .changeProfileImage(avatar_img: let avatar_img):
            params = ["avatar_img":avatar_img]
        case .profile:
            break
        case .changePassword(old_password: let old_password, password: let password, confirm_password: let confirm_password):
            params = ["old_password":old_password, "password":password, "confirm_password":confirm_password]
        case .wishlist:
            break
        case .deleteWishlist(wishlist_id: let wishlist_id):
            params = ["wishlist_id":wishlist_id]
        case .wishlistToCart(wishlist_id: let wishlist_id):
            params = ["wishlist_id": wishlist_id]
        case .placeOrder(shipping_address_id: let shipping_address_id, shipping_option_id: let shipping_option_id, billing_address_id: let billing_address_id, paymentMethod: let paymentMethod, extended_warrenty: let extended_warrenty, nonce: let nonce, payment_platform: let payment_platform):
            params = ["shipping_address_id": shipping_address_id, "shipping_option_id":shipping_option_id, "billing_address_id":billing_address_id, "paymentMethod":paymentMethod, "extended_warrenty":extended_warrenty, "nonce":nonce, "payment_platform":payment_platform]
        case .orderSummaryData(id: let id):
            params = ["id":id]
        case .prevOrder(page: let page, status: let status, time: let time, search: let search, limit: let limit):
            params = ["page":page, "status":status, "time":time, "search":search, "limit":limit]
        case .prevOrderDetails(id: let id):
            params = ["id":id]
        case .productRating(order_id: let order_id, order_detail_id: let order_detail_id, product_id: let product_id, rating: let rating):
            params = ["order_id": order_id, "order_detail_id": order_detail_id, "product_id": product_id, "rating": rating]
        case .cartDataUpdate(cart_count: let cart_count):
            params = ["cart_count":cart_count]
        case .editAddress(id: let id, name: let name, email: let email, mobile_number: let mobile_number, pincode: let pincode, address_line_1: let address_line_1, address_line_2: let address_line_2, city: let city, state: let state, default_address: let default_address, shipping_billing_address: let shipping_billing_address):
            params = ["id":id, "name":name, "email":email, "mobile_number":mobile_number, "pincode":pincode, "address_line_1":address_line_1, "address_line_2":address_line_2, "city":city, "state":state, "default_address":default_address, "shipping_billing_address":shipping_billing_address]
        case .zipcallus(zipcode: let zipcode):
            params = ["zipcode":zipcode]
        case .faq:
            break
        }
        
		return params
	}
	
    
	var headers: [String : String]? {
		var headers: [String : String] = [:]
		switch self {
			
        case .login, .signUp, .sendOTP, .verifyOTP, .resetPassword, .guestLogin:
            headers = ["Content-Type" : "application/json"]
            
            
        default:
            
            let userDefaults = UserDefaults.standard
            do {
                let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                headers = ["Content-Type" : "application/json",
                           "Authorization" : "Bearer " + (userDetail.token ?? "")]
            } catch {
                print(error.localizedDescription)
            }
        }
		return headers
	}
	
}
