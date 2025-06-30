//
//  EditProfileVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/02/24.
//

import UIKit
import moa


class EditProfileVC: UIViewController, XIBed {

    static func instantiate(profileApi: ProfileAPIProtocol, editProfileApi: EditProfileAPIProtocol, changeProfileImageApi: ChangeProfileImageAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.profileApi = profileApi
        vc.editProfileApi = editProfileApi
        vc.changeProfileImageApi = changeProfileImageApi
        return vc
    }
    
    var profileApi: ProfileAPIProtocol?
    var editProfileApi: EditProfileAPIProtocol?
    var changeProfileImageApi: ChangeProfileImageAPIProtocol?
    
    var profiledetails: ProfileDataResult?

    @IBOutlet weak var imageBaseVw: UIView!
    @IBOutlet weak var detailsBaseVw: UIView!
    @IBOutlet weak var changePwBaseVw: UIView!

    @IBOutlet weak var profileImageVw: UIImageView!
    
    @IBOutlet weak var fullNameBaseVw: UIView!
    @IBOutlet weak var emailIdBaseVw: UIView!
    @IBOutlet weak var mobileNumberBaseVw: UIView!
    @IBOutlet weak var dobBaseVw: UIView!
    
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var mobileNoTxtField: UITextField!
    @IBOutlet weak var dobTxtField: UITextField!
    var dateOfBirthDatepicker = UIDatePicker()
    
    @IBOutlet weak var saveButton: UIButton!
    
    var isEditProfile = false
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfileData()
    }
    
    func setProfileData() {
        let userDefaults = UserDefaults.standard
        do {
            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
            self.profileImageVw.moa.url = userDetail.avtar ?? ""
            self.fullNameTxtField.text = userDetail.fullName ?? ""
            self.emailTxtField.text = userDetail.email ?? ""
            self.mobileNoTxtField.text = userDetail.mobileNo ?? ""
            self.dobTxtField.text = userDetail.dob ?? ""
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupUI() {
        self.detailsBaseVw.layer.cornerRadius = 20.0
        self.changePwBaseVw.layer.cornerRadius = 20.0
        self.profileImageVw.layer.cornerRadius = Constants.Is_iPad ? self.profileImageVw.frame.size.height/2 : 25 //self.profileImageVw.frame.size.height/2
        self.saveButton.layer.cornerRadius = Constants.Is_iPad ? self.saveButton.frame.size.height/2 : 20 //self.saveButton.frame.size.height/2
        self.setView(view: self.fullNameBaseVw)
        self.setView(view: self.emailIdBaseVw)
        self.setView(view: self.mobileNumberBaseVw)
        self.setView(view: self.dobBaseVw)
        
        self.mobileNoTxtField.delegate = self
        self.dateOfBirthPickerSet()
    }
    
    func setView(view:UIView) {
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(hex: "#111113", alpha: 0.2).cgColor
    }
    
    func dateOfBirthPickerSet() {
        dateOfBirthDatepicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            dateOfBirthDatepicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        dateOfBirthDatepicker.maximumDate = Date()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolbar.backgroundColor = UIColor.white
        toolbar.tintColor = UIColor.black

        self.dobTxtField.inputView = dateOfBirthDatepicker
        self.dobTxtField.inputAccessoryView = toolbar
    }
    @objc func doneDatePicker() {
        dobTxtField.resignFirstResponder()
        let dateStr = Constants.formatDateForDisplay(date: dateOfBirthDatepicker.date)
        dobTxtField.text = dateStr
        self.view.endEditing(true)
    }
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func onChangePhotoBtnTap(_ sender: UIButton) {
        print("Change Photo Tap...")
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onChangePasswordBtnTap(_ sender: UIButton) {
        print("Change Password Tap...")
        let vc = ChangePasswordVC.instantiate(changePasswordApi: ChangePasswordAPI())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSaveBtnTap(_ sender: UIButton) {
        print("Save Btn Tap...")
        
        if !mobileNoTxtField.text!.elementsEqual("") {
            if !mobileValidation(value: self.mobileNoTxtField.text!) {
                showAlert(title: "Alert", message: "Please enter valid mobile number")
            } else {
                updateProfileDataApiCall()
            }
        } else {
            updateProfileDataApiCall()
        }
    }
    
    func fetchProfileData() {
        profileApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.profiledetails = response.data
                
                self?.profileImageVw.moa.url = self?.profiledetails?.user?.avatar ?? ""
                self?.fullNameTxtField.text = self?.profiledetails?.user?.fullname ?? ""
                self?.emailTxtField.text = self?.profiledetails?.user?.email ?? ""
                self?.mobileNoTxtField.text = self?.profiledetails?.user?.mobile ?? ""
                self?.dobTxtField.text = self?.profiledetails?.user?.dob ?? ""
                                
//                //==> Save in userdefaults.
//                let userDetail = UserDetails(fullName: self?.fullNameTxtField.text, mobileNo: self?.mobileNoTxtField.text, email: self?.emailTxtField.text, dob: self?.dobTxtField.text, avtar: self?.profiledetails?.user?.avatar ?? "")
//                let userDefaults = UserDefaults.standard
//                do {
//                    try userDefaults.setObject(userDetail, forKey: "UserDetailsData")
//                } catch {
//                    print(error.localizedDescription)
//                }

            } else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
    
    func updateProfileDataApiCall() {
        
        let fullName = self.fullNameTxtField.text ?? ""
        let mobileNo = self.mobileNoTxtField.text ?? ""
        let dob = self.dobTxtField.text ?? ""
        
        
        if fullName.elementsEqual("") && mobileNo.elementsEqual("") && dob.elementsEqual("") {
            self.showAlert(title: "Alert", message: "Please fill any one field")
        } else {
            print("Profile Update")
            editProfileApi?.getData(fullname: self.fullNameTxtField.text ?? "", mobile: self.mobileNoTxtField.text!, email: self.emailTxtField.text ?? "", dob: self.dobTxtField.text ?? "", completion: { [weak self] (data) in
                guard let response = data else { return }
                let isSuccess: Bool = response.success!
                
                if isSuccess {
                    self?.showAlert(title: "Success", message: response.message ?? "")
                    self?.fetchProfileData()
                } else {
                    self?.showAlert(title: "Alert", message: "Something went wrong.")
                }
            })
        }
    }
    
    func changeProfileImage(imgBase64: String) {
        changeProfileImageApi?.getData(imageBase64: imgBase64, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            if isSuccess {
                self?.showAlert(title: "Success", message: response.message ?? "")
                
                let imageUrl = response.data?.avatar ?? ""
                if imageUrl.elementsEqual("") {
                    self?.profileImageVw.image = UIImage(named: "ic_profile")
                } else {
                    self?.profileImageVw.moa.url = "\(Constants.baseProductionURL)\(imageUrl)"
                }
                
//                //==> Save model data in userdefaults...
//                let details = response.data
//                let userDetail = UserDetails(avtar: response.data?.avatar ?? "")
//                let userDefaults = UserDefaults.standard
//                do {
//                    try userDefaults.setObject(userDetail, forKey: "UserDetailsData")
//                } catch {
//                    print(error.localizedDescription)
//                }
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
}

//MARK: TextField Delegate.....
extension EditProfileVC: UITextFieldDelegate {
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

// MARK: - Profile API Protocol
protocol ProfileAPIProtocol {
    func getData(completion: @escaping ((ProfileDataModel?) -> Void))
}

struct ProfileAPI: ProfileAPIProtocol {
    func getData(completion: @escaping ((ProfileDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .profile) { (data:ProfileDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Edit Profile API Protocol
protocol EditProfileAPIProtocol {
    func getData(fullname:String, mobile:String, email:String, dob:String, completion: @escaping ((EditProfileDataModel?) -> Void))
}

struct EditProfileAPI: EditProfileAPIProtocol {
    func getData(fullname: String, mobile: String, email: String, dob: String, completion: @escaping ((EditProfileDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .updateProfile(fullname: fullname, mobile: mobile, email: email, dob: dob)) { (data:EditProfileDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Change Profile Image API Protocol
protocol ChangeProfileImageAPIProtocol {
    func getData(imageBase64:String, completion: @escaping ((EditProfileDataModel?) -> Void))
}

struct ChangeProfileImageAPI: ChangeProfileImageAPIProtocol {
    func getData(imageBase64: String, completion: @escaping ((EditProfileDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .changeProfileImage(avatar_img: imageBase64)) {(data:EditProfileDataModel?) in
            completion(data)
        }
    }
}


//MARK: ImagePicker Delegate...
extension EditProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate {
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.cameraCaptureMode = .photo
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //self.profileImageVw.image = pickedImage
            
            if let imageData = pickedImage.jpegData(compressionQuality: 0.50) {
                let base64ImageString = imageData.base64EncodedString(options: [])
                let base64String = "data:image/png;base64,\(base64ImageString)"
                self.changeProfileImage(imgBase64: "data:image/png;base64,\(base64String)")
            } else {
                print("No need to update Image")
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
