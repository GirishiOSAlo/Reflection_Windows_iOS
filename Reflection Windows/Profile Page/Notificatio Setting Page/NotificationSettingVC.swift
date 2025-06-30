//
//  NotificationSettingVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/02/24.
//

import UIKit

class NotificationSettingVC: UIViewController, XIBed {
    
    static func instantiate(notificationSettingsApi: NotificationSettingAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.notificationSettingsApi = notificationSettingsApi
        return vc
    }
    
    var notificationSettingsApi: NotificationSettingAPIProtocol?

    @IBOutlet weak var orderUpdatesBaseVw: UIView!
    @IBOutlet weak var promotionDealBaseVw: UIView!
    @IBOutlet weak var newProductBaseVw: UIView!
    @IBOutlet weak var deliveryInstallationBaseVw: UIView!
    @IBOutlet weak var rateReviewBaseVw: UIView!
    
    @IBOutlet weak var orderUpdateSelectImgVw: UIImageView!
    @IBOutlet weak var promotionDealSelectImgVw: UIImageView!
    @IBOutlet weak var newProductSelectImgVw: UIImageView!
    @IBOutlet weak var deliveryInstallationSelectImgVw: UIImageView!
    @IBOutlet weak var rateReviewSelectImgVw: UIImageView!
    
    var isOrderUpdate = 0
    var isPromotionDeal = 0
    var isNewProduct = 0
    var isDelivery = 0
    var isRating = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isOrderUpdate = userDefaults.isOrderUpdateNotification
        self.isPromotionDeal = userDefaults.isPromotionAndDealsNotification
        self.isNewProduct = userDefaults.isNewProductsNotification
        self.isDelivery = userDefaults.isDeliveryAndInstallationNotification
        self.isRating = userDefaults.isReviewsAndRatingsNotification
        self.setupUI()
    }
    
    func setupUI() {
        self.orderUpdatesBaseVw.layer.cornerRadius = 12.0
        self.promotionDealBaseVw.layer.cornerRadius = 12.0
        self.newProductBaseVw.layer.cornerRadius = 12.0
        self.deliveryInstallationBaseVw.layer.cornerRadius = 12.0
        self.rateReviewBaseVw.layer.cornerRadius = 12.0
        
        if self.isOrderUpdate == 1 {
            self.orderUpdateSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        } else {
            self.orderUpdateSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        }
        
        if self.isPromotionDeal == 1 {
            self.promotionDealSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        } else {
            self.promotionDealSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        }
        
        if self.isNewProduct == 1 {
            self.newProductSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        } else {
            self.newProductSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        }

        if self.isDelivery == 1 {
            self.deliveryInstallationSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        } else {
            self.deliveryInstallationSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        }

        if self.isRating == 1 {
            self.rateReviewSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        } else {
            self.rateReviewSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        }
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func onOrderUpdateBtnTap(_ sender: UIButton) {
        print("Order Update")
        if isOrderUpdate == 1 {
            isOrderUpdate = 0
            self.orderUpdateSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        } else {
            isOrderUpdate = 1
            self.orderUpdateSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        }
        userDefaults.isOrderUpdateNotification = self.isOrderUpdate
        fetchNotificationData(orderUpdate: self.isOrderUpdate, promotionDeal: self.isPromotionDeal, nreProduct: self.isNewProduct, delivery: self.isDelivery, customerReview: self.isRating)
    }
    
    @IBAction func onPromotionDealBtnTap(_ sender: UIButton) {
        print("Promotion & Deals")
        
        if self.isPromotionDeal == 1 {
            self.isPromotionDeal = 0
            self.promotionDealSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        } else {
            self.isPromotionDeal = 1
            self.promotionDealSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        }
        userDefaults.isPromotionAndDealsNotification = self.isPromotionDeal
        fetchNotificationData(orderUpdate: self.isOrderUpdate, promotionDeal: self.isPromotionDeal, nreProduct: self.isNewProduct, delivery: self.isDelivery, customerReview: self.isRating)
    }
    
    @IBAction func onNewProductBtnTap(_ sender: UIButton) {
        print("New Product")
        if self.isNewProduct == 1 {
            self.isNewProduct = 0
            self.newProductSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        } else {
            self.isNewProduct = 1
            self.newProductSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        }
        userDefaults.isNewProductsNotification = self.isNewProduct
        fetchNotificationData(orderUpdate: self.isOrderUpdate, promotionDeal: self.isPromotionDeal, nreProduct: self.isNewProduct, delivery: self.isDelivery, customerReview: self.isRating)
    }
    
    @IBAction func onDeliveryInstalltionBtnTap(_ sender: UIButton) {
        print("Delivery & Installation")
        if self.isDelivery == 1 {
            self.isDelivery = 0
            self.deliveryInstallationSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        } else {
            self.isDelivery = 1
            self.deliveryInstallationSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        }
        userDefaults.isDeliveryAndInstallationNotification = self.isDelivery
        fetchNotificationData(orderUpdate: self.isOrderUpdate, promotionDeal: self.isPromotionDeal, nreProduct: self.isNewProduct, delivery: self.isDelivery, customerReview: self.isRating)
    }
    
    @IBAction func onRateReviewBtnTap(_ sender: UIButton) {
        print("Rate & Review")
        if self.isRating == 1 {
            self.isRating = 0
            self.rateReviewSelectImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        } else {
            self.isRating = 1
            self.rateReviewSelectImgVw.image = UIImage(named: "ic_selectedCheckbox")
        }
        userDefaults.isReviewsAndRatingsNotification = self.isRating
        fetchNotificationData(orderUpdate: self.isOrderUpdate, promotionDeal: self.isPromotionDeal, nreProduct: self.isNewProduct, delivery: self.isDelivery, customerReview: self.isRating)
    }
    
    func fetchNotificationData(orderUpdate:Int, promotionDeal:Int, nreProduct:Int, delivery:Int, customerReview:Int) {
        notificationSettingsApi?.getData(order_updates_noti: orderUpdate, promotions_deal_noti: promotionDeal, new_products_noti: nreProduct, delivery_installation_noti: delivery, customer_review_rating_noti: customerReview, noti: "yes", completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.showAlert(title: "Success", message: response.message ?? "")
                
                self?.isOrderUpdate = response.data?.orderUpdatesNoti ?? 0
                self?.isPromotionDeal = response.data?.promotionsDealNoti ?? 0
                self?.isNewProduct = response.data?.newProductsNoti ?? 0
                self?.isDelivery = response.data?.deliveryInstallationNoti ?? 0
                self?.isRating = response.data?.customerReviewRatingNoti ?? 0
                self?.setupUI()

            } else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
}

// MARK: - Edit Profile API Protocol
protocol NotificationSettingAPIProtocol {
    func getData(order_updates_noti:Int, promotions_deal_noti:Int, new_products_noti:Int, delivery_installation_noti:Int, customer_review_rating_noti:Int, noti:String, completion: @escaping ((EditProfileDataModel?) -> Void))
}

struct NotificationSettingAPI: NotificationSettingAPIProtocol {
    func getData(order_updates_noti: Int, promotions_deal_noti: Int, new_products_noti: Int, delivery_installation_noti: Int, customer_review_rating_noti: Int, noti: String, completion: @escaping ((EditProfileDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .notificationSetting(order_updates_noti: order_updates_noti, promotions_deal_noti: promotions_deal_noti, new_products_noti: new_products_noti, delivery_installation_noti: delivery_installation_noti, customer_review_rating_noti: customer_review_rating_noti, noti: noti)) { (data:EditProfileDataModel?) in
            completion(data)
        }
    }
}
