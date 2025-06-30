//
//  OrderConfirmedPage.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 21/02/24.
//

import UIKit
import Lottie
import SVProgressHUD

class OrderConfirmedPage: UIViewController, XIBed {
    
    static func instantiate(orderSummaryApi: OrderSummaryAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.orderSummaryApi = orderSummaryApi
        return vc
    }
    
    var orderSummaryApi: OrderSummaryAPIProtocol?
    
    var orderSummaryResult: OrderSummaryOrder?
    var productsList: [OrderSummaryProduct] = []

    @IBOutlet weak var animationMainVw: UIView!
    @IBOutlet weak var animationVw: LottieAnimationView!
    
    @IBOutlet weak var estimatedBaseVw: UIView!
    @IBOutlet weak var productListBaseVw: UIView!
    @IBOutlet weak var productListVwHeight: NSLayoutConstraint!
    @IBOutlet weak var orderDetailBaseVw: UIView!
    @IBOutlet weak var paymentDetailBaseVw: UIView!
    @IBOutlet weak var shippingDetailsBaseVw: UIView!
    @IBOutlet weak var shippingDetailsBaseVwHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contactSupportBtn: UIButton!
    @IBOutlet weak var backToHomeBtn: UIButton!
    
    @IBOutlet weak var productListCollectionVw: UICollectionView!

    var orderId:Int!
    
    @IBOutlet weak var estimatedDeliveryDateLbl: UILabel!
    @IBOutlet weak var orderDateLbl: UILabel!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var orderTotalLbl: UILabel!
    
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var customizationLbl: UILabel!
    
    @IBOutlet weak var saleTaxTitleLbl: UILabel!
    @IBOutlet weak var salesTaxLbl: UILabel!

    @IBOutlet weak var shippingLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    
    @IBOutlet weak var shippingTitleLbl: UILabel!
    @IBOutlet weak var shippingAddressLbl: UILabel!
    @IBOutlet weak var shippingMobileNoLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func animationViewShow() {
        self.animationMainVw.alpha = 1.0
        self.animationMainVw.isHidden = false
        // 1. Set animation content mode
        animationVw.contentMode = .scaleAspectFit
        // 2. Set animation loop mode
        animationVw.loopMode = .playOnce
        // 3. Adjust animation speed
        animationVw.animationSpeed = 0.8
        // 4. Play animation
        animationVw.play { completed in
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                self.animationMainVw.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                self.animationMainVw.alpha = 0
                //self.animationMainVw.isHidden = true
                self.fetchOrderSummaryData()
            })
        }
    }
    
    func setupUI() {
        animationViewShow()
        
        self.estimatedBaseVw.layer.cornerRadius = 12.0
        self.productListBaseVw.layer.cornerRadius = 12.0
        self.orderDetailBaseVw.layer.cornerRadius = 12.0
        self.paymentDetailBaseVw.layer.cornerRadius = 12.0
        self.shippingDetailsBaseVw.layer.cornerRadius = 12.0
        
        self.contactSupportBtn.layer.cornerRadius = self.contactSupportBtn.frame.size.height/2
        self.contactSupportBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.contactSupportBtn.layer.borderWidth = 1.0
        self.backToHomeBtn.layer.cornerRadius = self.backToHomeBtn.frame.size.height/2
        self.backToHomeBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.backToHomeBtn.layer.borderWidth = 1.0

        productListCollectionVw.register(BillingProductListCVC.nib(), forCellWithReuseIdentifier: BillingProductListCVC.identifier)
        productListCollectionVw.delegate = self
        productListCollectionVw.dataSource = self

        //==> 2 value is count of product list count...
        //self.productListVwHeight.constant = (80.0 * 2) + 50.0
        self.productListVwHeight.constant = 0.0

    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        //self.navigationController?.popViewController(animated: true)
        userDefaults.type = 0
        self.navigationController?.popToViewController(ofClass: HomeTabBarVC.self)
    }

    @IBAction func onSeeProductDataBtnTap(_ sender: UIButton) {
        print("See Product Data...")
        let url = URL(string: self.orderSummaryResult?.submittalsURL ?? "")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func onDownloadInvoiceBtnTap(_ sender: UIButton) {
        print("Download Invoice...")
        let userDefaults = UserDefaults.standard
        do {
            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
            
            //"http://18.191.121.135:2100/api/orderInvoice?id=631&uid=645"
            guard let url = URL(string: Constants.baseProductionURL + "orderInvoice?id=\(self.orderId ?? 0)&uid=\(userDetail.userID ?? 0)") else {
                print("Invalid URL")
                return
            }
            //==> Open URL in browser...
            UIApplication.shared.open(url)

        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onConatctSupportBtnTap(_ sender: UIButton) {
        print("Contact Support...")
        userDefaults.type = 3
        let vc = HomeTabBarVC.instantiate()
        vc.isComeFromContact = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBackHomeBtnTap(_ sender: UIButton) {
        print("Back to Home...")
        userDefaults.type = 0
        let vc = HomeTabBarVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchOrderSummaryData() {
        orderSummaryApi?.getData(id: self.orderId, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.orderSummaryResult = response.data?.order
                DispatchQueue.main.async {
                    self?.setupData(obj: self?.orderSummaryResult)
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    func setupData(obj: OrderSummaryOrder?) {
        self.estimatedDeliveryDateLbl.text = obj?.estimatedDelivery ?? ""
        
        self.productsList = obj?.products ?? []
//        self.productListVwHeight.constant = CGFloat(80 * self.productsList.count) + 70.0
        
        var productListVwHeight = 0.0
        if self.productsList.count > 0 {
            for product in self.productsList {
                let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 200.0 : 128.0)
                let title = "\(product.category ?? "") - \(product.productName ?? "")"
                let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 23.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
                
                let totalPrice = "$\(product.totalPrice ?? "")"
                let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
                var swingOption = ""
                if product.leftSwing == 1 {
                    swingOption = "Left Hand Swing"
                } else if product.rightSwing == 1 {
                    swingOption = "Right Hand Swing"
                } else {
                    swingOption = ""
                }
                
                let glass = product.glass ?? ""
                let glassOption = product.glassOptions ?? ""
                let color = product.color ?? ""
                let anchorage = product.anchorage ?? ""
                let quantity = product.cartCount ?? 0
                let subDetail = "\(totalPrice),\n\(dimension), \(swingOption), \(glass), \(glassOption), \(color), \(anchorage), Insect Mesh, Qty = \(quantity)"
                let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
                
                let topBottomMargin = CGFloat(Constants.Is_iPad ? 50.0 : 27.0)
                let finalLblHeight = productNameHeight + subDetailHeight + topBottomMargin //27 = top bottom margin...
                
                let imageMargin = CGFloat(Constants.Is_iPad ? 105.0 : 78.0)
                if finalLblHeight < imageMargin {
                    productListVwHeight = productListVwHeight + imageMargin
                } else {
                    productListVwHeight = productListVwHeight + finalLblHeight
                }
            }
        }
        let viewHeight = CGFloat(Constants.Is_iPad ? 70.0 : 55.0)
        self.productListVwHeight.constant = productListVwHeight + viewHeight//70.0
                
        self.productsList = obj?.products ?? []
        self.productListCollectionVw.reloadData()
        
        self.orderDateLbl.text = "Order Date : \(obj?.orderDate ?? "")"
        self.orderNoLbl.text = "Order No : \(obj?.orderNo ?? "")"
        self.orderTotalLbl.text = "Order Total : \(obj?.orderTotal ?? "")"
        
        self.paymentModeLbl.text = "Payment Mode : \(obj?.paymentMode ?? "")"
        self.itemLbl.text = obj?.paymentItems ?? ""
        self.customizationLbl.text = obj?.paymentCustomization ?? ""
        
        self.saleTaxTitleLbl.text = "Tax (\(obj?.salestaxPercent ?? "")%)"
        self.salesTaxLbl.text = "+$\(obj?.salestax ?? "")"
        
        let shippingCharge:String = obj?.paymentShippingCharges ?? ""
        if shippingCharge.elementsEqual("$0") {
            self.shippingLbl.text = "Free"
        } else {
            self.shippingLbl.text = obj?.paymentShippingCharges ?? ""
        }
        self.totalPriceLbl.text = obj?.orderTotal ?? ""
        
        let shippingDetail = obj?.shippingAddress
        self.shippingTitleLbl.text = "Shipping to \(shippingDetail?.name ?? "")"
        self.shippingMobileNoLbl.text = shippingDetail?.mobileNumber ?? ""
        
        let addressLine1 = shippingDetail?.addressLine1 ?? ""
        let addressLine2 = shippingDetail?.addressLine2 ?? ""
        let city = shippingDetail?.city ?? ""
        let state = shippingDetail?.state ?? ""
        let pincode = shippingDetail?.pincode ?? ""
        self.shippingAddressLbl.text = "\(addressLine1), \(addressLine2), \(city), \(state) - \(pincode)"
        
        let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 120.0 : 64.0)
        let addressTitleLblHeight = self.heightForView(text: self.shippingTitleLbl.text ?? "", font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 20.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
        let addressLblHeight = self.heightForView(text: self.shippingAddressLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 20.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
        
        self.shippingDetailsBaseVwHeight.constant = addressTitleLblHeight + addressLblHeight + CGFloat(Constants.Is_iPad ? 140.0 : 80.0)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
}


extension OrderConfirmedPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.productListCollectionVw:
            return self.productsList.count 
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.productListCollectionVw:
            let cell = productListCollectionVw.dequeueReusableCell(withReuseIdentifier: BillingProductListCVC.identifier, for: indexPath) as! BillingProductListCVC
            
            let product = self.productsList[indexPath.row]
            cell.imgVw.moa.url = product.productImage ?? ""
            let title = "\(product.category ?? "") - \(product.productName ?? "")"
            cell.titleLbl.text = title
            
            let totalPrice = "$\(product.totalPrice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            var swingOption = ""
            if product.leftSwing == 1 {
                swingOption = "Left Hand Swing"
            } else if product.rightSwing == 1 {
                swingOption = "Right Hand Swing"
            } else {
                swingOption = ""
            }
            let glass = product.glass ?? ""
            let glassOption = product.glassOptions ?? ""
            let color = product.color ?? ""
            let anchorage = product.anchorage ?? ""
            let quantity = product.cartCount ?? 0
            cell.subTitleLbl.text = "\(totalPrice),\n\(dimension), \(swingOption), \(glass), \(glassOption), \(color), \(anchorage), Insect Mesh, Qty = \(quantity)"
            
            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case productListCollectionVw:
//            return CGSize(width: self.productListCollectionVw.frame.size.width, height: 80.0)
            var productListVwHeight = 0.0
            let product = self.productsList[indexPath.row]
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 200.0 : 128.0)
            let title = "\(product.category ?? "") - \(product.productName ?? "")"
            let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 23.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
            
            let totalPrice = "$\(product.totalPrice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            var swingOption = ""
            if product.leftSwing == 1 {
                swingOption = "Left Hand Swing"
            } else if product.rightSwing == 1 {
                swingOption = "Right Hand Swing"
            } else {
                swingOption = ""
            }
            let glass = product.glass ?? ""
            let glassOption = product.glassOptions ?? ""
            let color = product.color ?? ""
            let anchorage = product.anchorage ?? ""
            let quantity = product.cartCount ?? 0
            let subDetail = "\(totalPrice),\n\(dimension), \(swingOption), \(glass), \(glassOption), \(color), \(anchorage), Insect Mesh, Qty = \(quantity)"
            let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
            
            let topBottomMargin = CGFloat(Constants.Is_iPad ? 50.0 : 27.0)
            let finalLblHeight = productNameHeight + subDetailHeight + topBottomMargin
            
            let imageMargin = CGFloat(Constants.Is_iPad ? 105.0 : 78.0)
            if finalLblHeight < imageMargin {
                productListVwHeight = productListVwHeight + imageMargin
            } else {
                productListVwHeight = productListVwHeight + finalLblHeight
            }
            return CGSize(width: self.productListCollectionVw.frame.size.width, height: productListVwHeight)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}

// MARK: - Order Summary API Protocol
protocol OrderSummaryAPIProtocol {
    func getData(id: Int, completion: @escaping ((OrderSummaryDataModel?) -> Void))
}

struct OrderSummaryAPI: OrderSummaryAPIProtocol {
    func getData(id: Int, completion: @escaping ((OrderSummaryDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .orderSummaryData(id: id)) { (data:OrderSummaryDataModel?) in
            completion(data)
        }
    }
}
