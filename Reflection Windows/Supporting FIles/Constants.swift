//
//  Constants.swift
//  Divine
//
//  Created by Pranay Barua on 25/04/22.
//

import Foundation
import UIKit

struct Constants {
    
    struct ApplePay {
        static let MERCHANT_IDENTIFIER: String = "merchant.com.reflectionwindow.RWWManorCollection"
    }
    
    struct Square {
//        static let SAND_APPLICATION_ID: String = "sandbox-sq0idb-0oukfPr7gzCzeVVrpnEtvw"
        static let SAND_APPLICATION_ID: String = "sandbox-sq0idb-IQT9-X99j58OIwBgFBWHVA"
//        static let CHARGE_SERVER_HOST: String = "EAAAl_mD9NOWIe-9KCfsr6Uvo0wbgTT9sCDVBQ5ZOOPiVK6h5FlGtCAbiCu4dkg-"
//        static let CHARGE_URL: String = "LC7BG61WGPTAA"
        
        static let PRODUCTION_APPLICATION_ID: String = "sq0idp-tjTz8BoLiWm5tU5kcFNiRw"
        static let SQUARE_ACCESS_TOKEN = "EAAAl83ExiA5ZUzgBA4u5smoAf-STKkL8nJeXyHI2obr0do8jUNeMNaLCDKMtqqL"
//        static let PRODUCTION_APPLICATION_ID: String = "sq0idp-4X43eo_hboM2rb3o9i2ftQ"
//       static let SQUARE_ACCESS_TOKEN = "EAAAlq3k5Q4JpjrkQqLriJ50cOEMj5gY2DsDSalh3BJZAqHOp-dw8GndsbFnl0pN"
//       static let SQUARE_LOCATION_ID = "LGERHFC7X2TWT"
    }
    
    
    //public static var baseURL = "https://reflection-window.loca.lt/reflection-window/public/api/"
    //public static var baseURL = "http://15.207.140.145:2100/api/"
    
//    public static var baseProductionURL = "http://18.191.121.135:2100/api/"
    public static var baseProductionURL = "https://adminpanel.enerfinallc.com/api/"
    
    public static var isGuestLogin = false
    
    public static var termsOfSaleURL = "https://enerfinallc.com/terms-condition-of-sale/"
    public static var termsOfUseURL = "https://enerfinallc.com/terms-of-use/"
    public static var privacyPolicyURL = "https://enerfinallc.com/privacy-policy/"
    
    // KEYS
    // FreshChat
    static let freshChatAppID = "38aad727-8ce6-4aef-92f2-6973e3d3c9f6"//"28c5f36d-904b-44bd-a7cc-3fe6ec08df56"
    static let freshChatAppKey = "db595cdf-464f-44f2-9eb5-9b20eaa77481"//"13c95ec7-6fe7-4160-9590-4e53d9b1394b"
    static let freshChatDomain = "msdk.freshchat.com"//"msdk.in.freshchat.com"
    
    static let supportEmail = "info@enerfinallc.com"
    static let contactNumber = "844-312-2525"
    
    //Paypal
    static let paypalBaseURL = "https://api-m.sandbox.paypal.com/"
    static let paypalClientId = "AVduDykhsFebGpV4IR5N5S5zuZRkMSviM9-RnuQ5guTxy-Tr73rC5EE4ao-mYgA1NG7KtNUEG-43YL_w"
    static let paypalClientSecret = "EENkHeFiWOGwWdbQOajsqcL-rrWpesaSVoU_4KL65j9qR2ZUg16T9LBJM6S6ZLNwmuxVgp2sqLGRaT8k"
    static let paypalReturnURL = "app.reflectionwindow://paypalpay"
    
    
    static var categoryArr: [DashboardCollection] = []
    static var IsCartUpdate: Bool = false
    
    static var Is_iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    //==> Formats the date chosen with the date picker.
    public static func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
}

class userDefaults {
    
    public static var accessToken: String {
        get {
            UserDefaults.standard.string(forKey: "accessToken") ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
    
    public static var guestTokenID: String {
        get {
            UserDefaults.standard.string(forKey: "guestTokenID") ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: "guestTokenID")
        }
    }
    
    public static var type: Int {
        get {
            UserDefaults.standard.integer(forKey: "type")
        } set {
            UserDefaults.standard.set(newValue, forKey: "type")
        }
    }

    public static var isGuestLogin: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isGuestLogin")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isGuestLogin")
        }
    }
    
    public static var isLogin: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isLogin")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isLogin")
        }
    }

    public static var isCartEmpty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isCartEmpty")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isCartEmpty")
        }
    }
    
    public static var isWishlistEmpty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isWishlistEmpty")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isWishlistEmpty")
        }
    }


    public static var isOrderUpdateNotification: Int {
        get {
            UserDefaults.standard.integer(forKey: "isOrderUpdateNotification")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isOrderUpdateNotification")
        }
    }

    public static var isPromotionAndDealsNotification: Int {
        get {
            UserDefaults.standard.integer(forKey: "isPromotionAndDealsNotification")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isPromotionAndDealsNotification")
        }
    }

    public static var isNewProductsNotification: Int {
        get {
            UserDefaults.standard.integer(forKey: "isNewProductsNotification")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isNewProductsNotification")
        }
    }

    public static var isDeliveryAndInstallationNotification: Int {
        get {
            UserDefaults.standard.integer(forKey: "isDeliveryAndInstallationNotification")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isDeliveryAndInstallationNotification")
        }
    }

    public static var isReviewsAndRatingsNotification: Int {
        get {
            UserDefaults.standard.integer(forKey: "isReviewsAndRatingsNotification")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isReviewsAndRatingsNotification")
        }
    }

    public static var unique_Id: String {
        get {
            UserDefaults.standard.string(forKey: "unique_Id") ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: "unique_Id")
        }
    }

    public static var cartUpdateProductID: Int {
        get {
            UserDefaults.standard.integer(forKey: "cartUpdateProductID")
        } set {
            UserDefaults.standard.set(newValue, forKey: "cartUpdateProductID")
        }
    }

    public static var isCartEdit: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isCartEdit")
        } set {
            UserDefaults.standard.set(newValue, forKey: "isCartEdit")
        }
    }
    
}
