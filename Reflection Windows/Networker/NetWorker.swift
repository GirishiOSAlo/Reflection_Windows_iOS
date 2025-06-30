//
//  NetWorker.swift
//  NetWorker
//
//  Created by Chaitanya Soni on 04/02/21.
//  Copyright © 2021 Chaitanya Soni. All rights reserved.
//

//http://15.206.181.171/admin/customerLogin    mobile_no

import Foundation
import SVProgressHUD
import UIKit


public class NetWorker {
    
    public static var sessionID: String {
        get {
            UserDefaults.standard.string(forKey: "sessionID") ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: "sessionID")
        }
    }
    
    public static var isSessionExpired: Bool {
        get {
            if UserDefaults.standard.string(forKey: "isSessionExpired") != nil {
                let boolVal: String = UserDefaults.standard.string(forKey: "isSessionExpired") ?? "false"
                return (boolVal as NSString).boolValue
            } else {
                return true
            }
        }
        set {
            UserDefaults.standard.setValue("\(newValue)", forKey: "isSessionExpired")
        }
    }
    
    public static var deviceID = ""
    public static var fcmToken = ""
    public static var isShowNoInternet = true
    
    public var sessionTimeout: () -> () = {}
    public var showHud: () -> () = {}
    public var hideHud: () -> () = {}
    public var showMessageToUser: ((String) -> ())?
    private var invalidDataRetryCounter: Int = 0
    //    private let apiProvider = MoyaProvider<OneAppAuth>(plugins: [NetworkLoggerPlugin()])
    
    public init(alertCompletion: @escaping ((String) -> ())) {
        self.showMessageToUser = alertCompletion
      /* let trustKitConfigUAT = [
            kTSKSwizzleNetworkDelegates: true,
            kTSKPinnedDomains: [
                "smarthub.mintoak.com": [
                    kTSKExpirationDate: "2024-12-01",
                    kTSKPublicKeyHashes: [
                        "jQJTbIh0grw0/1TkHSumWb+Fs0Ggogr621gT3PvPKG0=",
                        "Vjs8r4z+80wjNcr1YKepWQboSIRi63WsWXhIMN+eWys="
                    ],
                ]
            ]
        ] as [String : Any]
        
        let trustKitConfigProduction = [
            kTSKSwizzleNetworkDelegates: true,
            kTSKPinnedDomains: [
                "hdfcmmp.mintoak.com" : [
                    kTSKExpirationDate: "2024-12-01",
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=",
                        "f0KW/FtqTjs108NpYj42SrGvOB2PpxIVM8nWxjPqJGE=",
                        "NqvDJlas/GRcYbcWE8S/IceH9cq77kg0jVhZeAPXq8k=",
                        "9+ze1cZgR9KO1kZrVDxA4HQ6voHRCSVNz4RdTCx4U8U=",
                        "KwccWaCgrnaw6tsrrSO61FgLacNgG2MMLq8GE6+oP5I="
                    ],
                ]
            ]
        ] as [String : Any] */
        
//        #if DEBUG
//        TrustKit.initSharedInstance(withConfiguration: trustKitConfigUAT)
//        #else
//        TrustKit.initSharedInstance(withConfiguration: trustKitConfigProduction)
//        #endif
        
    }
    func showAlert(message: String) {
        showMessageToUser?(message)
    }
    
    private func requestFromAuthType(_ authType: AuthCustom) -> (request: URLRequest, key: String, iv: String) {
        let auth = convert(auth: authType)
        
        // let key = auth.encryptionType == .RSA_AES ? randomString(length: 16) : kAES_SecretKey
        // let iv = randomString(length: 16)
        
        let url = auth.fullURL
        let method = auth.method
//        let params: [String: Any] = {
//            if auth.isRequestEncrypted {
//                if auth.encryptionType == .RSA_AES {
//                    return RSA_AES_CryptoHelper.getPayload(forParams: auth.params, aesKey: key, aesIV: iv)
//                } else {
//                    return AES_CryptoHelper.getPayload(forParams: auth.params, aesKey: key, aesIV: iv)
//                }
//            } else {
//                return auth.params
//            }
//        }()
        let params: [String: Any] = auth.params
        
        let headers = auth.headers
        
        let body = (try? JSONSerialization.data(withJSONObject: params, options: [])) ?? Data()
        
        //        let payload = (params["PAYLOAD"] as? String ?? "").data(using: .utf8) ?? Data()
        //        let payloadBase64 = Data(base64Encoded: body) ?? Data()
        //        let payloadString = String(data: payloadBase64, encoding: .utf8) ?? ""
        //        let decrypted = CryptoHelper.decrypt(payload: payloadBase64, aesKey: key, aesIV: iv)
        //        let decyptedString = String(data: decrypted, encoding: .utf8) ?? String()
        //        print(decyptedString)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        
        print("Endpoint - \(url)")
        print("Headers - \(String(describing: headers))")
        print("Params - \(params)")
        
        // return (request: request, key: key, iv: iv)
        return (request: request, key: "", iv: "")
    }
        
    
    public func callAPIService <T: Codable> (type: AuthCustom, completion: @escaping (T?) -> Void) {
        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(message: "Oops! No Internet Connection")
            }
        }else{
            if Constants.IsCartUpdate {
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.show()
            }
            
            let tuple = requestFromAuthType(type)
            
            let request = tuple.request
            // Unencrypted DB From Cache
            let configuration = URLSessionConfiguration.ephemeral
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            configuration.urlCache?.removeAllCachedResponses()
            // change the default configuration
            // before creating the session
            let session = URLSession(configuration: configuration)
            session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.global().async {
                    DispatchQueue.main.sync {
//                        self.hideHud()
                        SVProgressHUD.dismiss()
                        let httpResponseCode = (response as? HTTPURLResponse)?.statusCode
                        if httpResponseCode == 401 {
                            self.sessionTimeout()
                            if !NetWorker.isSessionExpired{
                                NetWorker.isSessionExpired = true
                                self.sessionTimeout()
                            }
                            return
                        } else if httpResponseCode == 502 {
                            self.showAlert(message: "Server Error")
                        }
                        
//                        self.sessionTimeout()
                        print("--- Entering Response ---")
                        let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                        print("Response :: \(responseString)")
                        
                        if responseString.isEmpty {
                            self.showAlert(message: "Invalid server response.")
                        }
                        
                        if let unencryptedResponse = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8) ?? Data(), options: []) as? [String: Any] {
                            let errorCode = unencryptedResponse["errorCode"] as? String
                            
                            if errorCode == "E105" {
//                                self.refreshAppKey {
//                                    self.callAPIService(type: type, completion: completion)
//                                }
                            } else {
                                
                                do  {
                                    
                                    let decodedData = try JSONDecoder().decode(T.self, from: data ?? Data())
                                    
                                    completion(decodedData)
                                    
                                } catch {
    //                                self.showAlert(message: "Something went wrong")
                                    print("Error : ",error)
                                    completion(nil)
                                }
                                SVProgressHUD.dismiss()
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
 
    func convert(auth: AuthCustom) -> AppAuth {
        switch auth {

        case .login(email: let email, password: let password, guest_session_id: let guest_session_id):
            return OneAppAuth.login(email: email, password: password, guest_session_id: guest_session_id)
        case .signUp(email: let email, password: let password, deviceToken: let deviceToken, guest_session_id: let guest_session_id):
            return OneAppAuth.signUp(email: email, password: password, deviceToken: deviceToken, guest_session_id: guest_session_id)
        case .sendOTP(email: let email, requestPlace: let requestPlace):
            return OneAppAuth.sendOTP(email: email, requestPlace: requestPlace)
        case .verifyOTP(email: let email, otp: let otp, noRegister: let noRegister):
            return OneAppAuth.verifyOTP(email: email, otp: otp, noRegister: noRegister)
        case .resetPassword(password: let password, cpassword: let cpassword, email: let email, unique_id: let unique_id):
            return OneAppAuth.resetPassword(password: password, cpassword: cpassword, email: email, unique_id: unique_id)
        case .guestLogin:
            return OneAppAuth.guestLogin
        case .dashboard:
            return OneAppAuth.dashboard
        case .resources:
            return OneAppAuth.resources
//        case .addToCart(product_id: let product_id, dimension: let dimension, customizer: let customizer):
//            return OneAppAuth.addToCart(product_id: product_id, dimension: dimension, customizer: customizer)
        case .cartData:
            return OneAppAuth.cartData
        case .deleteCart(cart_id: let cart_id):
            return OneAppAuth.deleteCart(cart_id: cart_id)
        case .addressList(type: let type):
            return OneAppAuth.addressList(type: type)
        case .addNewAddress(name: let name, email: let email, mobile_number: let mobile_number, pincode: let pincode, address_line_1: let address_line_1, address_line_2: let address_line_2, city: let city, state: let state, default_address: let default_address, shipping_billing_address: let shipping_billing_address):
            return OneAppAuth.addNewAddress(name: name, email: email, mobile_number: mobile_number, pincode: pincode, address_line_1: address_line_1, address_line_2: address_line_2, city: city, state: state, default_address: default_address, shipping_billing_address: shipping_billing_address)
        case .deleteAddress(type: let type, customer_address_id: let customer_address_id):
            return OneAppAuth.deleteAddress(type: type, customer_address_id: customer_address_id)
        case .productList(category_id: let category_id, cart_id: let cart_id):
            return OneAppAuth.productList(category_id: category_id, cart_id: cart_id)
        case .shippingOption(customer_address_id: let customer_address_id):
            return OneAppAuth.shippingOption(customer_address_id: customer_address_id)
        case .billingSummaryData(shipping_option_id: let shipping_option_id, shipping_address_id: let shipping_address_id):
            return OneAppAuth.billingSummaryData(shipping_option_id: shipping_option_id, shipping_address_id: shipping_address_id)
        case .logout:
            return OneAppAuth.logout
        case .updateProfile(fullname: let fullname, mobile: let mobile, email: let email, dob: let dob):
            return OneAppAuth.updateProfile(fullname: fullname, mobile: mobile, email: email, dob: dob)
        case .notificationSetting(order_updates_noti: let order_updates_noti, promotions_deal_noti: let promotions_deal_noti, new_products_noti: let new_products_noti, delivery_installation_noti: let delivery_installation_noti, customer_review_rating_noti: let customer_review_rating_noti, noti: let noti):
            return OneAppAuth.notificationSetting(order_updates_noti: order_updates_noti, promotions_deal_noti: promotions_deal_noti, new_products_noti: new_products_noti, delivery_installation_noti: delivery_installation_noti, customer_review_rating_noti: customer_review_rating_noti, noti: noti)
        case .changeProfileImage(avatar_img: let avatar_img):
            return OneAppAuth.changeProfileImage(avatar_img: avatar_img)
        case .profile:
            return OneAppAuth.profile
        case .changePassword(old_password: let old_password, password: let password, confirm_password: let confirm_password):
            return OneAppAuth.changePassword(old_password: old_password, password: password, confirm_password: confirm_password)
        case .wishlist:
            return OneAppAuth.wishlist
        case .deleteWishlist(wishlist_id: let wishlist_id):
            return OneAppAuth.deleteWishlist(wishlist_id: wishlist_id)
        case .wishlistToCart(wishlist_id: let wishlist_id):
            return OneAppAuth.wishlistToCart(wishlist_id: wishlist_id)
        case .placeOrder(shipping_address_id: let shipping_address_id, shipping_option_id: let shipping_option_id, billing_address_id: let billing_address_id, paymentMethod: let paymentMethod, extended_warrenty: let extended_warrenty, nonce: let nonce, payment_platform: let payment_platform):
            return OneAppAuth.placeOrder(shipping_address_id: shipping_address_id, shipping_option_id: shipping_option_id, billing_address_id: billing_address_id, paymentMethod: paymentMethod, extended_warrenty: extended_warrenty, nonce: nonce, payment_platform:payment_platform)
        case .orderSummaryData(id: let id):
            return OneAppAuth.orderSummaryData(id: id)
        case .prevOrder(page: let page, status: let status, time: let time, search: let search, limit: let limit):
            return OneAppAuth.prevOrder(page: page, status: status, time: time, search: search, limit: limit)
        case .prevOrderDetails(id: let id):
            return OneAppAuth.prevOrderDetails(id: id)
        case .productRating(order_id: let order_id, order_detail_id: let order_detail_id, product_id: let product_id, rating: let rating):
            return OneAppAuth.productRating(order_id: order_id, order_detail_id: order_detail_id, product_id: product_id, rating: rating)
        case .cartDataUpdate(cart_count: let cart_count):
            return OneAppAuth.cartDataUpdate(cart_count: cart_count)
        case .editAddress(id: let id, name: let name, email: let email, mobile_number: let mobile_number, pincode: let pincode, address_line_1: let address_line_1, address_line_2: let address_line_2, city: let city, state: let state, default_address: let default_address, shipping_billing_address: let shipping_billing_address):
            return OneAppAuth.editAddress(id: id, name: name, email: email, mobile_number: mobile_number, pincode: pincode, address_line_1: address_line_1, address_line_2: address_line_2, city: city, state: state, default_address: default_address, shipping_billing_address: shipping_billing_address)
        case .zipcallus(zipcode: let zipcode):
            return OneAppAuth.zipcallus(zipcode: zipcode)
        case .faq:
            return OneAppAuth.faq
        }
    }
        
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
        
}


import Network
let monitor = NWPathMonitor()

func checkInterwebs() -> Bool {
    var status = false
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            status = true  // online
        }
    }
    return status
}
func isConnectionAvailable() -> Bool {
    let reachability = try! Reachability()

    let networkStatus = reachability.connection

    return !(networkStatus == .unavailable)
}


