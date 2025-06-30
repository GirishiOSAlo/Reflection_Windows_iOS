//
//  ChangePasswordVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/02/24.
//

import UIKit

class ChangePasswordVC: UIViewController, XIBed {

    static func instantiate(changePasswordApi: ChangePasswordAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.changePasswordApi = changePasswordApi
        return vc
    }
    
    var changePasswordApi: ChangePasswordAPIProtocol?

    @IBOutlet weak var currentPasswordBaseVw: UIView!
    @IBOutlet weak var newPaswordBaseVw: UIView!
    @IBOutlet weak var confirmPasswordBaseVw: UIView!
    
    @IBOutlet weak var currentPwTxtField: UITextField!
    @IBOutlet weak var newPwTxtField: UITextField!
    @IBOutlet weak var confirmPwTxtField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        self.saveButton.layer.cornerRadius = self.saveButton.frame.size.height/2
        self.setView(view: self.currentPasswordBaseVw)
        self.setView(view: self.newPaswordBaseVw)
        self.setView(view: self.confirmPasswordBaseVw)
        
        self.currentPwTxtField.isSecureTextEntry = true
        self.newPwTxtField.isSecureTextEntry = true
        self.confirmPwTxtField.isSecureTextEntry = true
    }
    
    func setView(view:UIView) {
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(hex: "#111113", alpha: 0.2).cgColor
    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCurrentPwEyeBtnTap(_ sender: UIButton) {
        if self.currentPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.currentPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.currentPwTxtField.isSecureTextEntry = true
        }
    }

    @IBAction func onNewPwEyeBtnTap(_ sender: UIButton) {
        if self.newPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.newPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.newPwTxtField.isSecureTextEntry = true
        }
    }

    @IBAction func onConfirmPwEyeBtnTap(_ sender: UIButton) {
        if self.confirmPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.confirmPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.confirmPwTxtField.isSecureTextEntry = true
        }
    }

    @IBAction func onSaveBtnTap(_ sender: UIButton) {
        if changePasswordValidation() {
            changePasswordApiCall()
        }
    }
    
    func changePasswordValidation() -> Bool {
        if self.currentPwTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter Old Password")
            return false
        }
        else if self.newPwTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Please enter new password")
            return false
        }
        else if !isPasswordValid(self.newPwTxtField.text!) {
            showAlert(title: "Alert", message: "Please enter valid password with alphabet & numeric.")
            return false
        }
        else if self.confirmPwTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Please enter confirm password")
            return false
        }
        else if !isPasswordValid(self.confirmPwTxtField.text!) {
            showAlert(title: "Alert", message: "Please enter valid confirm password with alphabet & numeric.")
            return false
        }
        else if !self.newPwTxtField.text!.elementsEqual(self.confirmPwTxtField.text!) {
            showAlert(title: "Alert", message: "Please Enter New & Confirm Password same.")
            return false
        }
        else {
            return true
        }
    }
    
    func changePasswordApiCall() {
        changePasswordApi?.getData(old_password: self.currentPwTxtField.text ?? "", password: self.newPwTxtField.text ?? "", confirm_password: self.confirmPwTxtField.text ?? "", completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.showAlert(title: "Alert", message: response.message ?? "")
                let alert = UIAlertController(title: "Success", message: response.message ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { success in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true)
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Something Went Wrong")
            }
        })
    }
}

// MARK: - Change Password API Protocol
protocol ChangePasswordAPIProtocol {
    func getData(old_password: String, password: String, confirm_password: String, completion: @escaping ((ChangePasswordModel?) -> Void))
}

struct ChangePasswordAPI: ChangePasswordAPIProtocol {
    func getData(old_password: String, password: String, confirm_password: String, completion: @escaping ((ChangePasswordModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .changePassword(old_password: old_password, password: password, confirm_password: confirm_password)) { (data:ChangePasswordModel?) in
            completion(data)
        }
    }
}
