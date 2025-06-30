//
//  AddAddressVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 19/02/24.
//

import UIKit
import SVProgressHUD

class AddAddressVC: UIViewController, XIBed {
    
    static func instantiate(addAddressApi: AddAddressAPIProtocol, editAddressApi: EditAddressAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.addAddressApi = addAddressApi
        vc.editAddressApi = editAddressApi
        return vc
    }
    
    var addAddressApi: AddAddressAPIProtocol?
    var editAddressApi: EditAddressAPIProtocol?

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameBaseVw: UIView!
    @IBOutlet weak var emailBaseVw: UIView!
    @IBOutlet weak var mobileBaseVw: UIView!
    @IBOutlet weak var pincodeBaseVw: UIView!
    @IBOutlet weak var address_1BaseVw: UIView!
    @IBOutlet weak var address_2BaseVw: UIView!
    @IBOutlet weak var cityBaseVw: UIView!
    @IBOutlet weak var stateBaseVw: UIView!
    
    @IBOutlet weak var sameShippingAddressVw: UIView!
    @IBOutlet weak var sameShippingVwHeight: NSLayoutConstraint!
    @IBOutlet weak var markDefaultBaseVw: UIView!
    @IBOutlet weak var markDefaultBaseVwHeight: NSLayoutConstraint!
    
    @IBOutlet weak var proceedBtn: UIButton!
    
    @IBOutlet weak var sameAddCheckImgvw: UIImageView!
    @IBOutlet weak var defaultAddCheckImgVw: UIImageView!
    
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var emailAddressTxtField: UITextField!
    @IBOutlet weak var mobileNoTxtField: UITextField!
    @IBOutlet weak var pincodeTxtField: UITextField!
    @IBOutlet weak var address_1TxtField: UITextField!
    @IBOutlet weak var address_2TxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var stateTxtField: UITextField!
    
    var isComeFromProfileEdit = false
    var editShippingAddress: CustomerAddress?
    
    var isBillingAddress = false
    var defaultAddress = 0

    var selectedShippingAddress: CustomerAddress?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        if self.isBillingAddress {
            self.titleLbl.text = "Billing Address"
            self.markDefaultBaseVwHeight.constant = 0.0
            self.sameShippingVwHeight.constant = Constants.Is_iPad ? 58.0 : 48.0
        } else {
            self.titleLbl.text = "Shipping Address"
            self.markDefaultBaseVwHeight.constant = Constants.Is_iPad ? 58.0 : 48.0
            self.sameShippingVwHeight.constant = 0.0
        }
        
        if self.isComeFromProfileEdit {
            self.editAddressDataSetUp()
        }
        
        mobileNoTxtField.delegate = self
        
        self.sameAddCheckImgvw.image = UIImage(named: "ic_unselectedCheckbox")
        self.defaultAddCheckImgVw.image = UIImage(named: "ic_unselectedCheckbox")
        
        setView(view: self.nameBaseVw)
        setView(view: self.emailBaseVw)
        setView(view: self.mobileBaseVw)
        setView(view: self.pincodeBaseVw)
        setView(view: self.address_1BaseVw)
        setView(view: self.address_2BaseVw)
        setView(view: self.cityBaseVw)
        setView(view: self.stateBaseVw)
        
        self.proceedBtn.layer.cornerRadius = self.proceedBtn.frame.size.height/2
    }
    
    func setView(view: UIView) {
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(hex: "#111113", alpha: 0.2).cgColor
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onProceedBtnTap(_ sender: UIButton) {
        print("Proceed Button...")
        if proceedValidation() {
            if self.isComeFromProfileEdit {
                let id = self.editShippingAddress?.id ?? 0
                self.editAddressApiCall(id: id)
            }
            else if self.isBillingAddress {
                self.addNewAddressApiCall(type: "billing")
            } else {
                self.addNewAddressApiCall(type: "shipping")
            }
        }
    }
    
    @IBAction func onSameShippingAddressBtnTap(_ sender: UIButton) {
        if self.selectedShippingAddress == nil {
            self.showAlert(title: "Alert", message: "Please first make default address")
        }
        else {
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                if self.sameAddCheckImgvw.image == UIImage(named: "ic_unselectedCheckbox") {
                    self.sameAddCheckImgvw.image = UIImage(named: "ic_selectedCheckbox")
                    self.fullNameTxtField.text = self.selectedShippingAddress?.name ?? ""
                    self.emailAddressTxtField.text = self.selectedShippingAddress?.email ?? ""
                    self.mobileNoTxtField.text = self.selectedShippingAddress?.mobileNumber ?? ""
                    self.pincodeTxtField.text = self.selectedShippingAddress?.pincode ?? ""
                    self.address_1TxtField.text = self.selectedShippingAddress?.addressLine1 ?? ""
                    self.address_2TxtField.text = self.selectedShippingAddress?.addressLine2 ?? ""
                    self.cityTxtField.text = self.selectedShippingAddress?.city ?? ""
                    self.stateTxtField.text = self.selectedShippingAddress?.state ?? ""
                } else {
                    self.sameAddCheckImgvw.image = UIImage(named: "ic_unselectedCheckbox")
                    self.fullNameTxtField.text = ""
                    self.emailAddressTxtField.text = ""
                    self.mobileNoTxtField.text = ""
                    self.pincodeTxtField.text = ""
                    self.address_1TxtField.text = ""
                    self.address_2TxtField.text = ""
                    self.cityTxtField.text = ""
                    self.stateTxtField.text = ""
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func onMarkAsDefaultAddressBtnTap(_ sender: UIButton) {
        if self.defaultAddCheckImgVw.image == UIImage(named: "ic_unselectedCheckbox") {
            self.defaultAddCheckImgVw.image = UIImage(named: "ic_selectedCheckbox")
            self.defaultAddress = 1
        } else {
            self.defaultAddCheckImgVw.image = UIImage(named: "ic_unselectedCheckbox")
            self.defaultAddress = 0
        }
    }
    
    func proceedValidation() -> Bool {
        if self.fullNameTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter full name")
            return false
        }
        else if self.emailAddressTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter email address")
            return false
        }
        else if self.mobileNoTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter mobile number")
            return false
        }
        else if !mobileValidation(value: self.mobileNoTxtField.text!) {
            showAlert(title: "Alert", message: "Please enter valid mobile number")
            return false
        }
        else if self.pincodeTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter pincode")
            return false
        }
        else if self.address_1TxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter address line 1")
            return false
        }
//        else if self.address_2TxtField.text!.elementsEqual("") {
//            showAlert(title: "Alert", message: "Enter address line 2")
//            return false
//        }
        else if self.cityTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter city")
            return false
        }
        else if self.stateTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter state")
            return false
        }
        else {
            return true
        }
    }

    func addNewAddressApiCall(type: String) {
        addAddressApi?.getData(name: self.fullNameTxtField.text ?? "", email: self.emailAddressTxtField.text ?? "", mobile_number: self.mobileNoTxtField.text ?? "", pincode: self.pincodeTxtField.text ?? "", address_line_1: self.address_1TxtField.text ?? "", address_line_2: self.address_2TxtField.text ?? "", city: self.cityTxtField.text ?? "", state: self.stateTxtField.text ?? "", default_address: self.defaultAddress, shipping_billing_address: type, completion: { [weak self] (data) in
            
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func editAddressDataSetUp() {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.fullNameTxtField.text = self.editShippingAddress?.name ?? ""
            self.emailAddressTxtField.text = self.editShippingAddress?.email ?? ""
            self.mobileNoTxtField.text = self.editShippingAddress?.mobileNumber ?? ""
            self.pincodeTxtField.text = self.editShippingAddress?.pincode ?? ""
            self.address_1TxtField.text = self.editShippingAddress?.addressLine1 ?? ""
            self.address_2TxtField.text = self.editShippingAddress?.addressLine2 ?? ""
            self.cityTxtField.text = self.editShippingAddress?.city ?? ""
            self.stateTxtField.text = self.editShippingAddress?.state ?? ""
            
            let isDefault = self.editShippingAddress?.defaultAddress
            if isDefault == 1 {  //default address...
                self.defaultAddCheckImgVw.image = UIImage(named: "ic_selectedCheckbox")
            } else {  //not default address...
                self.defaultAddCheckImgVw.image = UIImage(named: "ic_unselectedCheckbox")
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func editAddressApiCall(id: Int) {
        editAddressApi?.getData(id: id, name: self.fullNameTxtField.text ?? "", email: self.emailAddressTxtField.text ?? "", mobile_number: self.mobileNoTxtField.text ?? "", pincode: self.pincodeTxtField.text ?? "", address_line_1: self.address_1TxtField.text ?? "", address_line_2: self.address_2TxtField.text ?? "", city: self.cityTxtField.text ?? "", state: self.stateTxtField.text ?? "", default_address: self.defaultAddress, shipping_billing_address: "shipping", completion: { [weak self] (data) in
            
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
}

//MARK: TextField Delegate.....
extension AddAddressVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.mobileNoTxtField {
            let allowedCharacterSet = CharacterSet.decimalDigits
            let enteredCharacterSet = CharacterSet(charactersIn: string)
            guard allowedCharacterSet.isSuperset(of: enteredCharacterSet) else {
                return false
            }
            // Check the total length of the text field
            let currentText = (textField.text ?? "") as NSString
            let newText = currentText.replacingCharacters(in: range, with: string) as NSString
            // Allow the change only if the total length is less than or equal to 10
            return newText.length <= 10
        }
        else {
            return true
        }
    }
}


// MARK: - Add Address API Protocol
protocol AddAddressAPIProtocol {
    func getData(name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String, completion: @escaping ((AddAddressDataModel?) -> Void))
}

struct AddAddressAPI: AddAddressAPIProtocol {
    func getData(name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String, completion: @escaping ((AddAddressDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .addNewAddress(name: name, email: email, mobile_number: mobile_number, pincode: pincode, address_line_1: address_line_1, address_line_2: address_line_2, city: city, state: state, default_address: default_address, shipping_billing_address: shipping_billing_address)) { (data: AddAddressDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Add Address API Protocol
protocol EditAddressAPIProtocol {
    func getData(id: Int,name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String, completion: @escaping ((AddAddressDataModel?) -> Void))
}

struct EditAddressAPI: EditAddressAPIProtocol {
    func getData(id: Int,name: String, email: String, mobile_number: String, pincode: String, address_line_1: String, address_line_2: String, city: String, state: String, default_address: Int, shipping_billing_address: String, completion: @escaping ((AddAddressDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .editAddress(id: id, name: name, email: email, mobile_number: mobile_number, pincode: pincode, address_line_1: address_line_1, address_line_2: address_line_2, city: city, state: state, default_address: default_address, shipping_billing_address: shipping_billing_address)) { (data: AddAddressDataModel?) in
            completion(data)
        }
    }
}
