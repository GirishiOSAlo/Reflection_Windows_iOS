//
//  HelpCenterDetailsVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 26/03/24.
//

import UIKit
import FreshchatSDK

class HelpCenterDetailsVC: UIViewController, XIBed {
    
    var selectedOrder: PreOrderData?
    var selectedProduct: PreOrderProduct?
    var status:String!
    var subTitle: String!
    
    @IBOutlet weak var bottomDetailVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!

    @IBOutlet weak var estimatedBaseVw: UIView!
    @IBOutlet weak var deliveryTitleLbl: UILabel!
    @IBOutlet weak var estimatedDeliveryDateLbl: UILabel!

    @IBOutlet weak var productMainVw: UIView!
    @IBOutlet weak var productImgVw: UIImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var productSubTitleLbl: UILabel!
    @IBOutlet weak var rateView: StarRateView!

    @IBOutlet weak var productListTblVw: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.estimatedBaseVw.layer.cornerRadius = 12.0
        self.productMainVw.layer.cornerRadius = 12.0
        self.setupData(obj: self.selectedProduct)

        DispatchQueue.main.async {
            self.bottomDetailVw.roundCorners(corners: [.topLeft, .topRight], radius: 16.0)
            self.bottomDetailVw.layoutIfNeeded()
            self.bottomDetailVw.dropShadow(color: .black)
        }
        
        //Get Data from userdefaults...
        let userDefaults = UserDefaults.standard
        do {
            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
            let name = userDetail.fullName ?? ""
            if name.elementsEqual("") {
                self.titleLbl.text = "Hi User,\nlet us help you with your queries."
            } else {
                self.titleLbl.text = "Hi \(name),\nlet us help you with your queries."
            }
        } catch {
            print(error.localizedDescription)
        }

        self.chatBtn.layer.cornerRadius = self.chatBtn.frame.size.height/2
        self.callBtn.layer.cornerRadius = self.callBtn.frame.size.height/2
        self.callBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.callBtn.layer.borderWidth = 1.0

        
        productListTblVw.register(HelpCenterProductDetailsTVC.nib(), forCellReuseIdentifier: HelpCenterProductDetailsTVC.indentifier)
        productListTblVw.delegate = self
        productListTblVw.dataSource = self
        
        self.productListTblVw.reloadData()
    }
    
    func setupData(obj: PreOrderProduct?) {
        self.deliveryTitleLbl.text = self.status
        self.estimatedDeliveryDateLbl.text = self.selectedOrder?.estimatedDelivery
        
//        self.productImgVw.moa.url = obj?.productImage ?? ""
//        self.productTitleLbl.text = obj?.productName ?? ""
//        
//        let totalPrice = "$\(obj?.totalPrice ?? "")"
//        let dimension = "\(obj?.width ?? "") X \(obj?.height ?? "")"
//        let color = obj?.color ?? ""
//        self.productSubTitleLbl.text = "\(totalPrice),\n\(dimension), \(color)"
//        
//        self.rateView.ratingValue = obj?.rating ?? 0
//        self.rateView.isUserInteractionEnabled = false
    }
    
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onCallUsBtnTap(_ sender: UIButton) {
        print("Call Us...")
    }
    
    @IBAction func onChatBtnTap(_ sender: UIButton) {
        print("Chat With Us...")
        
//        User order no. 20240401133729.
//        Order Date: 01 Apr 2024
//        Window: Window one 1 x 1 inch Seashell White
        
        let orderNo = self.selectedOrder?.orderNo ?? ""
        let orderDate = self.selectedOrder?.orderDate ?? ""
        let windowDetail = "\(self.selectedProduct?.productName ?? ""), \(self.selectedProduct?.width ?? "") x \(self.selectedProduct?.height ?? "") inch, \(self.selectedProduct?.color ?? "")"
        
        let message = "User order no. \(orderNo) \n Order Date: \(orderDate) \n Window: \(windowDetail)"
        let freshchatMessage = FreshchatMessage.init(message: message,
        andTag: "single_match_tag")
        Freshchat.sharedInstance().send(freshchatMessage)
        Freshchat.sharedInstance().showConversations(self)
    }
}

//MARK: UITableview Delegate Method.....
extension HelpCenterDetailsVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productListTblVw.dequeueReusableCell(withIdentifier: HelpCenterProductDetailsTVC .indentifier, for: indexPath) as! HelpCenterProductDetailsTVC
        
        cell.productImgVw.moa.url = self.selectedProduct?.productImage ?? ""
        
        cell.productTitleLbl.text = self.selectedProduct?.productName ?? ""
        
        let totalPrice = "$\(self.selectedProduct?.totalPrice ?? "")"
        let dimension = "\(self.selectedProduct?.width ?? "") X \(self.selectedProduct?.height ?? "") inch"
        let color = self.selectedProduct?.color ?? ""
        cell.productSubTitleLbl.text = "\(totalPrice),\n\(dimension), \(color)"
        
        cell.rateView.ratingValue = self.selectedProduct?.rating ?? 0
        cell.rateView.isUserInteractionEnabled = false
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
