//
//  BillingDetailsVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 19/02/24.
//

import UIKit
import moa
import WebKit

class BillingDetailsVC: UIViewController, XIBed {

    static func instantiate(billingSummaryApi: BillingSummaryAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.billingSummaryApi = billingSummaryApi
        return vc
    }
    
    var billingSummaryApi: BillingSummaryAPIProtocol?
    
    var billinSummaryResult: BillingSummaryResult?
    var cartList: [BillingSummaryCart] = []

    var shippingAddressId = 0
    var shippingOptionId = 0
    var billingAddressId = 0

    @IBOutlet weak var productListMainVw: UIView!
    @IBOutlet weak var productDetailsVwHeight: NSLayoutConstraint!
    @IBOutlet weak var paymentDetailsVw: UIView!
    @IBOutlet weak var termsOfUseMainVw: UIView!
    @IBOutlet weak var termsMainVw: UIView!
    @IBOutlet weak var privacyMainVw: UIView!
    @IBOutlet weak var estimatedMainVw: UIView!
    @IBOutlet weak var proceedBtn: UIButton!
    
    @IBOutlet weak var productListCollectionVw: UICollectionView!
    
    @IBOutlet weak var warrantyCheckBtn: UIButton!
    @IBOutlet weak var termsCheckBtn: UIButton!
    
    var readMoreText = "Read More"
    @IBOutlet weak var extendedWarrantyLbl: UILabel!
    var warrantyShortText = ""
    var warrentyFullText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa min"
    
    @IBOutlet weak var termsLbl: UILabel!
    var termShortText = ""
    var termFullText = "Please read T&C and allow"//"Lorem ipsum dolor sit amet, consectetur"
    var isWarrentyExtended = 0
    
    @IBOutlet weak var mainPopupVw: UIView!
    @IBOutlet weak var termsSubPopupVw: UIView!
    @IBOutlet weak var termsContinueBtn: UIButton!
    @IBOutlet weak var termsPopupCheckBtn: UIButton!
    @IBOutlet weak var termsWebBaseVw: UIView!
    var termsWebView: WKWebView!
    
    @IBOutlet weak var termsOfUseSubPopupVw: UIView!
    @IBOutlet weak var termsOfUseContinueBtn: UIButton!
    @IBOutlet weak var termsOfUsePopupCheckBtn: UIButton!
    @IBOutlet weak var termsOfUseMainVwWebBaseVw: UIView!
    var termsOfUseWebView: WKWebView!
    
    @IBOutlet weak var privacySubPopupVw: UIView!
    
    @IBOutlet weak var extendedWarrantyStackVw: UIStackView!
    
    @IBOutlet weak var itemsAmountLbl: UILabel!
    @IBOutlet weak var loyalAmountLbl: UILabel!
    @IBOutlet weak var shippingFeeLbl: UILabel!
    
    @IBOutlet weak var saleTaxTitleLbl: UILabel!
    @IBOutlet weak var salesTaxLbl: UILabel!
    @IBOutlet weak var extendedWarrantyPriceLbl: UILabel!
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var estimatedDateLbl: UILabel!
    
    
    
    @IBOutlet weak var privacyWebBaseVw: UIView!
    var privacyWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchBillingSummaryData()
        self.setWarrentyWedView()
        self.setTermsWedView()
        self.setPrivacyyWedView()
    }

    func setTermsWedView() {
        termsWebView = WKWebView()
        termsWebView.translatesAutoresizingMaskIntoConstraints = false
        self.termsWebBaseVw.addSubview(termsWebView)
        
        NSLayoutConstraint.activate([
            termsWebView.topAnchor.constraint(equalTo: self.termsWebBaseVw.topAnchor),
            termsWebView.bottomAnchor.constraint(equalTo: self.termsWebBaseVw.bottomAnchor),
            termsWebView.leadingAnchor.constraint(equalTo: self.termsWebBaseVw.leadingAnchor),
            termsWebView.trailingAnchor.constraint(equalTo: self.termsWebBaseVw.trailingAnchor)
        ])
        
        if let url = URL(string: Constants.termsOfSaleURL) {
            let request = URLRequest(url: url)
            termsWebView.load(request)
        }
    }
    
    func setWarrentyWedView() {
        termsOfUseWebView = WKWebView()
        termsOfUseWebView.navigationDelegate = self
        termsOfUseWebView.scrollView.delegate = self
        termsOfUseWebView.translatesAutoresizingMaskIntoConstraints = false
        self.termsOfUseMainVwWebBaseVw.addSubview(termsOfUseWebView)
        
        NSLayoutConstraint.activate([
            termsOfUseWebView.topAnchor.constraint(equalTo: self.termsOfUseMainVwWebBaseVw.topAnchor),
            termsOfUseWebView.bottomAnchor.constraint(equalTo: self.termsOfUseMainVwWebBaseVw.bottomAnchor),
            termsOfUseWebView.leadingAnchor.constraint(equalTo: self.termsOfUseMainVwWebBaseVw.leadingAnchor),
            termsOfUseWebView.trailingAnchor.constraint(equalTo: self.termsOfUseMainVwWebBaseVw.trailingAnchor)
        ])
        
        if let url = URL(string: Constants.termsOfUseURL) {
            let request = URLRequest(url: url)
            termsOfUseWebView.load(request)
        }
    }
    
    func setPrivacyyWedView() {
        privacyWebView = WKWebView()
        privacyWebView.translatesAutoresizingMaskIntoConstraints = false
        self.privacyWebBaseVw.addSubview(privacyWebView)
        
        NSLayoutConstraint.activate([
            privacyWebView.topAnchor.constraint(equalTo: self.privacyWebBaseVw.topAnchor),
            privacyWebView.bottomAnchor.constraint(equalTo: self.privacyWebBaseVw.bottomAnchor),
            privacyWebView.leadingAnchor.constraint(equalTo: self.privacyWebBaseVw.leadingAnchor),
            privacyWebView.trailingAnchor.constraint(equalTo: self.privacyWebBaseVw.trailingAnchor)
        ])
        
        if let url = URL(string: Constants.privacyPolicyURL) {
            let request = URLRequest(url: url)
            privacyWebView.load(request)
        }
    }

    func setupUI() {
        
        self.mainPopupVw.isHidden = true
        self.termsSubPopupVw.isHidden = true
        self.termsSubPopupVw.layer.cornerRadius = 12.0
        self.termsContinueBtn.layer.cornerRadius = self.termsContinueBtn.frame.size.height/2
        self.termsOfUseSubPopupVw.isHidden = true
        self.termsOfUseSubPopupVw.layer.cornerRadius = 12.0
        self.termsOfUseContinueBtn.layer.cornerRadius = self.termsOfUseContinueBtn.frame.size.height/2
        self.privacySubPopupVw.isHidden = true
        self.privacySubPopupVw.layer.cornerRadius = 12.0
        
        self.proceedBtn.layer.cornerRadius = self.proceedBtn.frame.size.height/2
        self.extendedWarrantyStackVw.isHidden = true
        self.proceedBtnBtnDisable()
        
        self.productListMainVw.layer.cornerRadius = 12.0
        self.paymentDetailsVw.layer.cornerRadius = 12.0
        self.termsOfUseMainVw.layer.cornerRadius = 12.0
        self.termsMainVw.layer.cornerRadius = 12.0
        self.privacyMainVw.layer.cornerRadius = 12.0
        self.estimatedMainVw.layer.cornerRadius = 12.0
        self.isWarrentyExtended = 0
        
        productListCollectionVw.register(BillingProductListCVC.nib(), forCellWithReuseIdentifier: BillingProductListCVC.identifier)
        productListCollectionVw.delegate = self
        productListCollectionVw.dataSource = self

        //==> 2 value is count of product list...
        self.productDetailsVwHeight.constant = 0.0
        
        self.warrantyCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        self.termsCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        self.termsPopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        
//        //=> Warranty Text Add Read More & Tap Action....
//        let maxCharacterCount = 70
//        if warrentyFullText.count > maxCharacterCount {
//            let index = warrentyFullText.index(warrentyFullText.startIndex, offsetBy: maxCharacterCount)
//            self.warrantyShortText = String(warrentyFullText.prefix(upTo: index))
//        } else {
//            // The description is already 100 characters or less
//        }
//        extendedWarrantyLbl.numberOfLines = 0
//        extendedWarrantyLbl.isUserInteractionEnabled = true
//        warrantyShortText = warrantyShortText + " " + readMoreText
//        updateWarrantyLabel(withText: warrantyShortText)

//        //=> Terms Text Add Read More & Tap Action....
//        let maxCharacterCount1 = 35
//        if termFullText.count > maxCharacterCount1 {
//            let index = termFullText.index(termFullText.startIndex, offsetBy: maxCharacterCount1)
//            self.termShortText = String(termFullText.prefix(upTo: index))
//        } else {
//            // The description is already 100 characters or less
//        }
//        termsLbl.numberOfLines = 0
//        termsLbl.isUserInteractionEnabled = true
//        termShortText = termShortText + " " + readMoreText
//        updateTermsLabel(withText: termShortText)
        
        self.setTermsConditionLabel()
        self.setWarrantyLabel()
        self.setPrivacyLabel()
    }
    
    func setTermsConditionLabel() {
        self.termsLbl.text = "Please read Terms of Sale before processing."
        let labelAttriString = NSMutableAttributedString(string: termsLbl.text!)
        let range1 = (termsLbl.text! as NSString).range(of: "Terms of Sale")
        labelAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range1)
        
        termsLbl.attributedText = labelAttriString
//        termsLbl.isUserInteractionEnabled = true
//        termsLbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapTermsLabel(gesture:))))
    }
    @objc func tapTermsLabel(gesture: UITapGestureRecognizer) {
        let range = (termsLbl.text! as NSString).range(of: "Terms of Sale")
        if gesture.didTapAttributedTextInLabel(label: self.termsLbl, inRange: range) {
            print("Tapped Terms of Sale")
            self.mainPopupVw.isHidden = false
            self.termsSubPopupVw.isHidden = false
        } else {
            print("Tapped None")
        }
    }
    
    func setWarrantyLabel() {
        self.extendedWarrantyLbl.text = "Please read Terms of Use before processing."
        let labelAttriString = NSMutableAttributedString(string: extendedWarrantyLbl.text!)
        let range1 = (extendedWarrantyLbl.text! as NSString).range(of: "Terms of Use")
        labelAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range1)
        
        extendedWarrantyLbl.attributedText = labelAttriString
//        extendedWarrantyLbl.isUserInteractionEnabled = true
//        extendedWarrantyLbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapWarrantyLabel(gesture:))))
    }
    @objc func tapWarrantyLabel(gesture: UITapGestureRecognizer) {
        let range = (extendedWarrantyLbl.text! as NSString).range(of: "warranty details")
        if gesture.didTapAttributedTextInLabel(label: self.extendedWarrantyLbl, inRange: range) {
            print("Tapped Terms of Use")
            self.mainPopupVw.isHidden = false
            self.termsOfUseSubPopupVw.isHidden = false
        } else {
            print("Tapped None")
        }
    }
    
    func setPrivacyLabel() {
        self.privacyLbl.text = "Please read Privacy Policy."
        let labelAttriString = NSMutableAttributedString(string: privacyLbl.text!)
        let range1 = (privacyLbl.text! as NSString).range(of: "Privacy Policy")
        labelAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range1)
        
        privacyLbl.attributedText = labelAttriString
    }
    
    @IBAction func onTermsOfUseOpen(_ sender: UIButton) {
        self.mainPopupVw.isHidden = false
        self.termsOfUseSubPopupVw.isHidden = false
        self.termsOfUsePopupCheckBtn.isEnabled = false
        self.termsOfUseContinueBtnDisable()
        self.termsOfUseWebView.scrollView.setContentOffset(.zero, animated: false)
        self.warrantyCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
    }
    
    @IBAction func onTermsOpen(_ sender: UIButton) {
        self.mainPopupVw.isHidden = false
        self.termsSubPopupVw.isHidden = false
    }
    
    @IBAction func onPrivacyPolicyOpen(_ sender: UIButton) {
        self.setPrivacyyWedView()
        self.mainPopupVw.isHidden = false
        self.privacySubPopupVw.isHidden = false
    }
    //    func updateWarrantyLabel(withText text: String) {
//        let attributedString = NSMutableAttributedString(string: text)
//        if text == warrantyShortText {
//            let range = (text as NSString).range(of: readMoreText)
//            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-SemiBold", size: 12.0)!, range: range)
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range)
//            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//        }
//        extendedWarrantyLbl.attributedText = attributedString
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapWarrantyLabel(tap:)))
//        self.extendedWarrantyLbl.addGestureRecognizer(tap)
//        self.extendedWarrantyLbl.isUserInteractionEnabled = true
//    }
//    @objc func tapWarrantyLabel(tap: UITapGestureRecognizer) {
//        let readMoreText = (warrantyShortText as NSString).range(of: readMoreText)
//        if tap.didTapAttributedTextInLabel(label: self.extendedWarrantyLbl, inRange: readMoreText) {
//            print("Read More Warranty tapped.")
//            self.mainPopupVw.isHidden = false
//            self.warrantySubPopupVw.isHidden = false
//        } else {
//            print("Other Tapped")
//        }
//    }

//    func updateTermsLabel(withText text: String) {
//        let attributedString = NSMutableAttributedString(string: text)
//        if text == termShortText {
//            let range = (text as NSString).range(of: readMoreText)
//            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-SemiBold", size: 12.0)!, range: range)
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range)
//            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//        }
//        termsLbl.attributedText = attributedString
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTermsLabel(tap:)))
//        self.termsLbl.addGestureRecognizer(tap)
//        self.termsLbl.isUserInteractionEnabled = true
//    }
//    @objc func tapTermsLabel(tap: UITapGestureRecognizer) {
//        let readMoreText = (termShortText as NSString).range(of: readMoreText)
//        if tap.didTapAttributedTextInLabel(label: self.termsLbl, inRange: readMoreText) {
//            print("Read More Terms tapped.")
//            self.mainPopupVw.isHidden = false
//            self.termsSubPopupVw.isHidden = false
//        } else {
//            print("Other Tapped")
//        }
//    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onProceedBtnTap(_ sender: UIButton) {
        print("Proceed Button...")
        let finalAmount = self.billinSummaryResult?.total ?? ""
        let vc = PaymentOptionsVC.instantiate(orderPlaceApi: OrderPlaceAPI(), finalAmount: finalAmount)
        vc.isWarrentyExtended = self.isWarrentyExtended
        vc.shippingAddressId = self.shippingAddressId
        vc.shippingOptionId = self.shippingOptionId
        vc.billingAddressId = self.billingAddressId
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func proceedBtnBtnEnable() {
        self.proceedBtn.isUserInteractionEnabled = true
        self.proceedBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func proceedBtnBtnDisable() {
        self.proceedBtn.isUserInteractionEnabled = false
        self.proceedBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }

    
    @IBAction func onWarrantyCheckBtnTap(_ sender: UIButton) {
        if self.warrantyCheckBtn.imageView!.image == UIImage(named: "ic_unselectedCheckbox") {
            self.isWarrentyExtended = 1
            self.extendedWarrantyStackVw.isHidden = false
            self.extendedWarrantyPriceLbl.text = "+$\(billinSummaryResult?.extendedWarrenty ?? "")"
            self.totalAmountLbl.text = "$\(billinSummaryResult?.totalExtendedWarrenty ?? "")"
            
            self.warrantyCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
            self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
        }
        else {
            self.isWarrentyExtended = 0
            self.extendedWarrantyStackVw.isHidden = true
            self.extendedWarrantyPriceLbl.text = "+$0"
            self.totalAmountLbl.text = "$\(billinSummaryResult?.total ?? "")"

            self.warrantyCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
            self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        }
    }
    
    @IBAction func onTermsCheckBtnTap(_ sender: UIButton) {
        if self.termsCheckBtn.imageView!.image == UIImage(named: "ic_unselectedCheckbox") {
            self.termsCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
            self.termsPopupCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
        } else {
            self.termsCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
            self.termsPopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        }
        proceedBtnCheck()
    }
    
    func proceedBtnCheck() {
        let selectedCheckBoxImg = UIImage(named: "ic_selectedCheckbox")
//        if self.warrantyCheckBtn.imageView!.image == selectedCheckBoxImg && self.termsCheckBtn.imageView!.image == selectedCheckBoxImg {
        if self.termsCheckBtn.imageView!.image == selectedCheckBoxImg {
            proceedBtnBtnEnable()
        } else {
            proceedBtnBtnDisable()
        }
    }
    
    @IBAction func onTermsPopupCloseBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.termsSubPopupVw.isHidden = true
    }
    
    @IBAction func onTermsContinueBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.termsSubPopupVw.isHidden = true
    }
    
    @IBAction func onTermsPopupCheckBtnTap(_ sender: UIButton) {
        if self.termsPopupCheckBtn.imageView!.image == UIImage(named: "ic_unselectedCheckbox") {
            self.termsCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
            self.termsPopupCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
        } else {
            self.termsCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
            self.termsPopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
        }
        proceedBtnCheck()
    }
    
    
    //Terms Of Use.....
    func termsOfUseContinueBtnEnable() {
        self.termsOfUseContinueBtn.isUserInteractionEnabled = true
        self.termsOfUseContinueBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func termsOfUseContinueBtnDisable() {
        self.termsOfUseContinueBtn.isUserInteractionEnabled = false
        self.termsOfUseContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    @IBAction func onTermsofUsePopupCloseBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.termsOfUseSubPopupVw.isHidden = true
    }
    
    @IBAction func onTermsofUseContinueBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.termsOfUseSubPopupVw.isHidden = true
    }
    
    @IBAction func onTermsOfUsePopupCheckBtnTap(_ sender: UIButton) {
        if self.termsOfUsePopupCheckBtn.imageView!.image == UIImage(named: "ic_unselectedCheckbox") {
            self.isWarrentyExtended = 1
            self.extendedWarrantyStackVw.isHidden = true
            self.extendedWarrantyPriceLbl.text = "+$\(billinSummaryResult?.extendedWarrenty ?? "")"
            self.totalAmountLbl.text = "$\(billinSummaryResult?.totalExtendedWarrenty ?? "")"

            self.warrantyCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
            self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_selectedCheckbox"), for: .normal)
            
            //Continue Button enable.....
            self.termsOfUseContinueBtnEnable()
            
        }
        else {
            self.isWarrentyExtended = 0
            self.extendedWarrantyStackVw.isHidden = true
            self.extendedWarrantyPriceLbl.text = "+$0"
            self.totalAmountLbl.text = "$\(billinSummaryResult?.total ?? "")"

            self.warrantyCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
            self.termsOfUsePopupCheckBtn.setImage(UIImage(named: "ic_unselectedCheckbox"), for: .normal)
            self.termsOfUseContinueBtnDisable()
        }
    }
    
    @IBAction func onPrivacyPopupCloseBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.privacySubPopupVw.isHidden = true
    }
    
    func fetchBillingSummaryData() {
        billingSummaryApi?.getData(shipping_option_id: self.shippingOptionId, shipping_address_id: self.shippingAddressId, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                
                self?.billinSummaryResult = response.data
                self?.cartList = self?.billinSummaryResult?.carts ?? []
                DispatchQueue.main.async {
                    self?.setData(result: self?.billinSummaryResult)
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func setData(result: BillingSummaryResult?) {
        
        var productListVwHeight = 0.0
        if self.cartList.count > 0 {
            for product in self.cartList {
                let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 200.0 : 128.0)
                let title = "\(product.categoryName ?? "") - \(product.productName ?? "")"
                let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 23.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
                
                let totalPrice = "$\(product.finalprice ?? "")"
                let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
                var swingOption = ""
                //Swing Option View add text.....
                if product.isSwing == 0 {
                    swingOption = ""
                } else {
                    if product.leftSwing == 1 {
                        swingOption = "Left Hand Swing"
                    } else if product.rightSwing == 1 {
                        swingOption = "Right Hand Swing"
                    } else {
                        swingOption = ""
                    }
                }
                let glass = product.customizer?[0].name ?? ""
                //Glass Sub Option View add text.....
                var glassOption = ""
                let subOptions = product.customizer?[0].options ?? []
                if subOptions.count == 0 {
                    glassOption = ""
                }
                else {
                    for (i,obj) in subOptions.enumerated() {
                        let name = obj.name
                        if i == (subOptions.count - 1) {
                            glassOption.append(name)
                        } else {
                            let str = "\(name), "
                            glassOption.append(str)
                        }
                    }
                }
                let color = product.customizer?[1].name ?? ""
                let anchorage = product.customizer?[2].name ?? ""
                let quantity = product.cartCount ?? 0
                let subDetail = "\(totalPrice),\n\(dimension), \(swingOption), \(glass), \(glassOption), \(color), \(anchorage), Insect Mesh, Qty = \(quantity)"
                let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
                
                let topBottomMargin = CGFloat(Constants.Is_iPad ? 50.0 : 27.0)
                let finalLblHeight = productNameHeight + subDetailHeight + topBottomMargin //22 = top bottom margin...
                
                let imageMargin = CGFloat(Constants.Is_iPad ? 105.0 : 78.0)
                if finalLblHeight < imageMargin {
                    productListVwHeight = productListVwHeight + imageMargin
                } else {
                    productListVwHeight = productListVwHeight + finalLblHeight
                }
            }
        }
        let viewHeight = CGFloat(Constants.Is_iPad ? 40.0 : 20.0)
        self.productDetailsVwHeight.constant = productListVwHeight + viewHeight//30.0
        self.productListCollectionVw.reloadData()
        
        self.itemsAmountLbl.text = "$\(result?.subtotal ?? "")"
        //self.loyalAmountLbl.text = "+$\(result?.loyalty ?? "")"
        
        let shippingCharge:String = result?.shipping ?? ""
        if shippingCharge.elementsEqual("") {
            self.shippingFeeLbl.text = "Free"
        } else {
            self.shippingFeeLbl.text = "+$\(result?.shipping ?? "")"
        }

        self.saleTaxTitleLbl.text = "Tax (\(result?.salestaxPercent ?? "")%)"
        self.salesTaxLbl.text = "+$\(result?.salestax ?? "")"
        self.totalAmountLbl.text = "$\(result?.total ?? "")"
        self.estimatedDateLbl.text = result?.estimatedate ?? ""
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


extension BillingDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.productListCollectionVw:
            return self.cartList.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.productListCollectionVw:
            let cell = productListCollectionVw.dequeueReusableCell(withReuseIdentifier: BillingProductListCVC.identifier, for: indexPath) as! BillingProductListCVC
            
            let product = self.cartList[indexPath.row]
            cell.imgVw.moa.url = product.productImage ?? ""
            let title = "\(product.categoryName ?? "") - \(product.productName ?? "")"
            cell.titleLbl.text = title
            
            let totalPrice = "$\(product.finalprice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            var swingOption = ""
            //Swing Option View add text.....
            if product.isSwing == 0 {
                swingOption = ""
            } else {
                if product.leftSwing == 1 {
                    swingOption = "Left Hand Swing,"
                } else if product.rightSwing == 1 {
                    swingOption = "Right Hand Swing,"
                } else {
                    swingOption = ""
                }
            }
            let glass = product.customizer?[0].name ?? ""
            //Glass Sub Option View add text.....
            var glassOption = ""
            let subOptions = product.customizer?[0].options ?? []
            if subOptions.count == 0 {
                glassOption = ""
            }
            else {
                for (i,obj) in subOptions.enumerated() {
                    let name = obj.name
                    if i == (subOptions.count - 1) {
                        glassOption.append(name)
                    } else {
                        let str = "\(name), "
                        glassOption.append(str)
                    }
                }
            }
            let color = product.customizer?[1].name ?? ""
            let anchorage = product.customizer?[2].name ?? ""
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
//            return CGSize(width: self.productListCollectionVw.frame.size.width, height: 90.0)

            var productListVwHeight = 0.0
            let product = self.cartList[indexPath.row]
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 200.0 : 128.0)
            let title = "\(product.categoryName ?? "") - \(product.productName ?? "")"
            let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 23.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
            
            let totalPrice = "$\(product.finalprice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            var swingOption = ""
            //Swing Option View add text.....
            if product.isSwing == 0 {
                swingOption = ""
            } else {
                if product.leftSwing == 1 {
                    swingOption = "Left Hand Swing"
                } else if product.rightSwing == 1 {
                    swingOption = "Right Hand Swing"
                } else {
                    swingOption = ""
                }
            }
            
            let glass = product.customizer?[0].name ?? ""
            var glassOption = ""
            
            //Glass Sub Option View add text.....
            let subOptions = product.customizer?[0].options ?? []
            if subOptions.count == 0 {
                glassOption = ""
            }
            else {
                for (i,obj) in subOptions.enumerated() {
                    let name = obj.name
                    if i == (subOptions.count - 1) {
                        glassOption.append(name)
                    } else {
                        let str = "\(name), "
                        glassOption.append(str)
                    }
                }
            }
            
            let color = product.customizer?[1].name ?? ""
            let anchorage = product.customizer?[2].name ?? ""
            let quantity = product.cartCount ?? 0
            
            let subDetail = "\(totalPrice),\n\(dimension), \(swingOption), \(glass), \(glassOption), \(color), \(anchorage), Insect Mesh, Qty = \(quantity)"
            let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
            
            let topBottomMargin = CGFloat(Constants.Is_iPad ? 50.0 : 27.0)
            let finalLblHeight = productNameHeight + subDetailHeight + topBottomMargin //27 = top bottom margin...
            
            let imageMargin = CGFloat(Constants.Is_iPad ? 105.0 : 80.0)
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

// MARK: - UIScrollViewDelegate Method
extension BillingDetailsVC: WKNavigationDelegate, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.termsOfUseWebView.scrollView {
            let scrollViewHeight = scrollView.frame.size.height
            let scrollContentSizeHeight = scrollView.contentSize.height
            let scrollOffset = scrollView.contentOffset.y
            
            // Check if the scroll position is at the bottom
            if scrollOffset + scrollViewHeight >= scrollContentSizeHeight {
                //print("Reached the bottom of the terms of use web view")
                self.termsOfUsePopupCheckBtn.isEnabled = true
            }
        }
        else if scrollView == self.termsOfUseWebView.scrollView {
        }
    }
}

// MARK: - Dashboard API Protocol
protocol BillingSummaryAPIProtocol {
    func getData(shipping_option_id: Int, shipping_address_id: Int, completion: @escaping ((BillingSummaryDataModel?) -> Void))
}

struct BillingSummaryAPI: BillingSummaryAPIProtocol {
    func getData(shipping_option_id: Int, shipping_address_id: Int, completion: @escaping ((BillingSummaryDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .billingSummaryData(shipping_option_id: shipping_option_id, shipping_address_id:shipping_address_id)) { (data: BillingSummaryDataModel?) in
            completion(data)
        }
    }
}
