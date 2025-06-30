//
//  ContactsViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/02/24.
//

import UIKit
import FreshchatSDK

class ContactsViewController: UIViewController, XIBed {

    static func instantiate(zipcallusApi: ZipCallAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.zipcallusApi = zipcallusApi
        return vc
    }
    
    var zipcallusApi: ZipCallAPIProtocol?

    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var callPopupMainVw: UIView!
    @IBOutlet weak var subPopupVw: UIView!
    @IBOutlet weak var subPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var popupLbl: UILabel!
    
    @IBOutlet weak var numberBaseVw: UIView!
    @IBOutlet weak var zipCodeBaseVw: UIView!
    @IBOutlet weak var zipCodeContinueBtn: UIButton!
    @IBOutlet weak var zipCodeEnterBaseVw: UIView!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var zipCodeCollectionVw: UICollectionView!
    var phoneNoArr: [String] = ["844-312-2525"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        self.subPopupVwHeight.constant = 0.0
        self.chatBtn.isHidden = true
//        let userDefaults = UserDefaults.standard
//        do {
//            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
//            let name = userDetail.fullName ?? ""
//            if name.elementsEqual("") {
//                self.titleLbl.text = "Hi User,\nlet us help you with your queries."
//            } else {
//                self.titleLbl.text = "Hi \(name),\nlet us help you with your queries."
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
        
        self.zipCodeTextField.delegate = self
        self.zipCodeTextField.keyboardType = .numberPad
        
        if Constants.Is_iPad {
            self.chatBtn.layer.cornerRadius = 15
            self.callBtn.layer.cornerRadius = 15
        } else {
            self.chatBtn.layer.cornerRadius = self.chatBtn.frame.size.height / 2
            self.callBtn.layer.cornerRadius = self.callBtn.frame.size.height / 2
        }
        self.view.layoutIfNeeded()
        
        
        self.callBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.callBtn.layer.borderWidth = 1.0
        self.callPopupMainVw.isHidden = true
        self.subPopupVw.layer.cornerRadius = 12.0
        self.popupLbl.text = "Enter your ZIP code to connect with the customer care of the respective area"
        self.zipCodeContinueBtn.layer.cornerRadius = self.zipCodeContinueBtn.frame.size.height/2
        self.zipCodeEnterBaseVw.layer.cornerRadius = 12.0
        self.zipCodeEnterBaseVw.layer.borderColor = UIColor(hex: "#11111333", alpha: 0.2).cgColor
        self.zipCodeEnterBaseVw.layer.borderWidth = 1.0
        
        registerCell()
        self.zipCodeCollectionVw.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.isGuestLogin {
            self.chatBtn.isHidden = true
        } else {
            self.chatBtn.isHidden = false
        }
    }
    
    func registerCell() {
        zipCodeCollectionVw.register(ZipCodeCVC.nib(), forCellWithReuseIdentifier: ZipCodeCVC.identifier)
        zipCodeCollectionVw.delegate = self
        zipCodeCollectionVw.dataSource = self

    }

    @IBAction func onChatBtnTap(_ sender: UIButton) {
        print("Chat with us..")
        Freshchat.sharedInstance().showConversations(self)
    }
    
    
    @IBAction func onCallBtnTap(_ sender: UIButton) {
        print("Call us..")
        self.callPopupMainVw.isHidden = false
        self.zipCodeBaseVw.isHidden = true
        self.numberBaseVw.isHidden = false
        self.zipCodeTextField.text = ""
        self.popupLbl.text = ""//Enter your ZIP code to connect with the customer care of the respective area"
        
        var totalHeight = 0.0
        for phone in self.phoneNoArr {
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 795.0 : 102.0)
            let phoneNoCellHeight = self.heightForView(text: phone, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 25.0 : 16.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
            let topBottomMargin = CGFloat(Constants.Is_iPad ? 40.0 : 20.0)
            totalHeight = totalHeight + phoneNoCellHeight + topBottomMargin
        }
        
        let titleLblHeight = self.heightForView(text: self.popupLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 640.0 : 78.0))
        totalHeight = totalHeight + titleLblHeight + CGFloat(Constants.Is_iPad ? 125.0 : 80.0)
        self.subPopupVwHeight.constant = totalHeight
        
        let vwHeight = self.view.frame.size.height - 200.0
        if totalHeight > vwHeight {
            self.subPopupVwHeight.constant = vwHeight
        } else {
            self.subPopupVwHeight.constant = totalHeight
        }
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
    
    @IBAction func onPopupCloseBtnTap(_ sender: UIButton) {
//        if self.zipCodeBaseVw.isHidden {
//            self.zipCodeBaseVw.isHidden = false
//            self.popupLbl.text = "Enter your ZIP code to connect with the customer care of the respective area"
//        } else {
            self.callPopupMainVw.isHidden = true
//        }
    }
    
    @IBAction func onZipCodeContinueBtnTap(_ sender: UIButton) {
        if self.zipCodeTextField.text!.elementsEqual("") {
            self.showAlert(title: "Alert!", message: "Please first enter ZIP code")
        } else {
            
            //self.zipCodeTextField.text = "99547"
            self.callZipCallApi(zipcode: self.zipCodeTextField.text ?? "")
        }
    }
    
    
    @IBAction func onDetectHoleBtnTap(_ sender: UIButton) {
        let vc = DetectHoleVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func callZipCallApi(zipcode: String) {
        zipcallusApi?.getData(zipcode: zipcode, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                
                let telephoneStr = response.data?.telephoneNumber ?? ""
                self?.phoneNoArr = telephoneStr.components(separatedBy: " ")
                self?.zipCodeCollectionVw.reloadData()
                
                self?.zipCodeBaseVw.isHidden = true
                self?.numberBaseVw.isHidden = false
                self?.popupLbl.text = "These Representative are available in your area. Use any of the numbers to reach out to us."

            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
}

// MARK: - UITextField Delegate Method...
extension ContactsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}


// MARK: - Zip Call API Protocol
protocol ZipCallAPIProtocol {
    func getData(zipcode: String, completion: @escaping ((ZipcallDataModel?) -> Void))
}

struct ZipCallAPI: ZipCallAPIProtocol {
    func getData(zipcode: String, completion: @escaping ((ZipcallDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .zipcallus(zipcode: zipcode)) { (data:ZipcallDataModel?) in
            completion(data)
        }
    }
}

//MARK: CollectionView Delegate Method...
extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.zipCodeCollectionVw:
            return self.phoneNoArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.zipCodeCollectionVw:
            let cell = zipCodeCollectionVw.dequeueReusableCell(withReuseIdentifier: ZipCodeCVC.identifier, for: indexPath) as! ZipCodeCVC
            
            cell.phoneNoLbl.text = self.phoneNoArr[indexPath.row]
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case zipCodeCollectionVw:
            //return CGSize(width: self.zipCodeCollectionVw.frame.size.width, height: 45.0)
            var totalHeight = 0.0
            let phone = phoneNoArr[indexPath.row]
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 795.0 : 102.0)
            let phoneNoCellHeight = self.heightForView(text: phone, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 25.0 : 16.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - leadingTraillingMargin)
            let topBottomMargin = CGFloat(Constants.Is_iPad ? 40.0 : 20.0)
            totalHeight = totalHeight + phoneNoCellHeight + topBottomMargin
            return CGSize(width: self.zipCodeCollectionVw.frame.size.width, height: totalHeight)

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case zipCodeCollectionVw:
            let phoneNumber = phoneNoArr[indexPath.row] // Replace with the phone number you want to call
            if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                print("Unable to open the phone dialer.")
            }
            
        default:
            break
        }
    }
}

