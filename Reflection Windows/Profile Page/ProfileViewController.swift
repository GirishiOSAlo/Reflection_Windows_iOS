//
//  ProfileViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/02/24.
//

import UIKit
import SVProgressHUD

class ProfileViewController: UIViewController, XIBed {
    
    
    static func instantiate(profileApi: ProfileAPIProtocol, logoutApi: LogoutAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.profileApi = profileApi
        vc.logoutApi = logoutApi
        return vc
    }
    
    var profileApi: ProfileAPIProtocol?
    var logoutApi: LogoutAPIProtocol?
    
    var profiledetails: ProfileDataResult?
    
    @IBOutlet weak var profileImgVw: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var yourOrderBaseVw: UIView!
    @IBOutlet weak var helpCenterBaseVw: UIView!
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var accountSettingCollectionVw: UICollectionView!
    @IBOutlet weak var accountSettingCollectionHeight: NSLayoutConstraint!
    var titleListArr = ["Edit Profile","Saved Address","Notification Setting","Log Out", "Delete Account"]
    var imgListArr = ["profileIcon","locationIcon","settingIcon","loginIcon", "ic_deleteAcc"]
    
    @IBOutlet weak var logoutPopupBaseVw: UIView!
    @IBOutlet weak var logoutSubView: UIView!
    
    @IBOutlet weak var deletePopupBaseVw: UIView!
    @IBOutlet weak var deleteSubView: UIView!
    
    
    @IBOutlet weak var enterOTPMainVw: UIView!
    @IBOutlet weak var otpTitleLbl: UILabel!
    @IBOutlet weak var otpView: DPOTPView!
    @IBOutlet weak var enterOTPContinueBtn: UIButton!
    @IBOutlet weak var enterOtpEditMailLbl: UILabel!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var timerLbl: UILabel!
    var timer:Timer? = nil
    var totalSecond: Int = 20
    var seconds: Int = 0
    var minutes: Int = 0
    var userEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfileData()
    }
    
    func setupUI() {
        self.enterOTPMainVw.isHidden = true
        self.profileImgVw.layer.cornerRadius = Constants.Is_iPad ? self.profileImgVw.layer.frame.size.height/2 : 25
        
        let attributedString = NSMutableAttributedString(string: self.profileNameLbl.text ?? "")
        let range = (self.profileNameLbl.text as? NSString)!.range(of: "Hello")
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: 20.0) ?? UIFont.systemFont(ofSize: 20), range: range)
        profileNameLbl.attributedText = attributedString
        
        self.yourOrderBaseVw.layer.cornerRadius = 12.0
        self.helpCenterBaseVw.layer.cornerRadius = 12.0
        self.logoutPopupBaseVw.isHidden = true
        self.logoutSubView.layer.cornerRadius = 16.0
        
        self.deletePopupBaseVw.isHidden = true
        self.deleteSubView.layer.cornerRadius = 16.0
        
        self.otpView.dpOTPViewDelegate = self
        
        accountSettingCollectionVw.register(AccountSettingCVC.nib(), forCellWithReuseIdentifier: AccountSettingCVC.identifier)
        accountSettingCollectionVw.delegate = self
        accountSettingCollectionVw.dataSource = self
        
        self.baseView.layer.cornerRadius = 12.0
        if Constants.Is_iPad {
            self.accountSettingCollectionHeight.constant = CGFloat(self.titleListArr.count) * 70.0
        } else {
            self.accountSettingCollectionHeight.constant = CGFloat(self.titleListArr.count) * 50.0
        }
        self.accountSettingCollectionVw.reloadData()
    }
    
    func fetchProfileData() {
        profileApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.profiledetails = response.data
                
                let imgUrl = self?.profiledetails?.user?.avatar ?? ""
                if imgUrl.elementsEqual("") {
                    self?.profileImgVw.image = UIImage(named: "ic_profile")
                } else {
                    self?.profileImgVw.moa.url = imgUrl
                }
                
                let userName = self?.profiledetails?.user?.fullname ?? ""
                if userName.elementsEqual("") {
                    self?.profileNameLbl.text = "Hello, User"
                } else {
                    self?.profileNameLbl.text = "Hello, \(userName)"
                }
                self?.userEmail = self?.profiledetails?.user?.email ?? ""
                self?.setupEnterOtpVw()
            } else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
    
    
    @IBAction func onYourOrderBtnTap(_ sender: Any) {
        print("Your Orders....")
        let vc = MyOrderVC.instantiate(preOrderApi: PreOrderAPI())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onHelpCenterBtnTap(_ sender: UIButton) {
        print("Help Center....")
        let vc = HelpCenterVC.instantiate(preOrderApi: PreOrderAPI())
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Logout Popup Button Actions...
    @IBAction func onLogoutDoneBtnTap(_ sender: UIButton) {
        logoutApiCall()
    }
    
    @IBAction func onLogoutCancelBtnTap(_ sender: UIButton) {
        self.logoutPopupBaseVw.isHidden = true
    }
    
    //MARK: Delete Popup Button Actions...
    @IBAction func onDeleteDoneBtnTap(_ sender: UIButton) {
        callDeleteAPI()
    }
    
    @IBAction func onDeleteCancelBtnTap(_ sender: UIButton) {
        self.deletePopupBaseVw.isHidden = true
    }
    
    //MARK: Enter OTP Action...
    @IBAction func onEnterOtpContinueBtnTap(_ sender: UIButton) {
        print("Enter OTP Continue...")
        
        self.enterOTPMainVw.isHidden = true
        self.stopTimer()
        if otpView.text != "" {
            let IntOtp = Int(otpView.text!) ?? 0
            validateDeleteOtp(otp: IntOtp)
        } else {
            showAlert(title: "Alert", message: "Please Enter Otp")
        }
    }
    
}

//MARK: API Calls
extension ProfileViewController {
    
    func logoutApiCall() {
        logoutApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                DispatchQueue.main.async {
                    self?.logoutPopupBaseVw.isHidden = true
                    //                    userDefaults.isLogin = false
                    //                    userDefaults.isGuestLogin = true
                    //                    userDefaults.isCartEmpty = true
                    //                    userDefaults.isWishlistEmpty = true
                    //
                    //                    let userData = UserDefaults.standard
                    //                    userData.removeObject(forKey: "UserDetailsData")
                    //                    userDefaults.isOrderUpdateNotification = 0
                    //                    userDefaults.isPromotionAndDealsNotification = 0
                    //                    userDefaults.isNewProductsNotification = 0
                    //                    userDefaults.isDeliveryAndInstallationNotification = 0
                    //                    userDefaults.isReviewsAndRatingsNotification = 0
                    //                    userDefaults.accessToken = ""
                    
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    
                    //self?.navigationController?.popToRootViewController(animated: true)
                    let vc = LoginVC.instantiate(loginApi: LoginAPI(), signupApi: SignUPAPI(), sendOtpApi: SendOtpAPI(), verifyOtpApi: VerifyOtpAPI(), resetPwApi: ResetPwAPI(), guestLoginApi: GuestLoginAPI())
                    guard let navigationController = self?.navigationController else { return }
                    var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
                    navigationArray.removeAll()
                    navigationArray.append(vc) //To remove all previous UIViewController and append the sign in view controller in navigation stack
                    self?.navigationController?.viewControllers = navigationArray
                    self?.navigationController?.popViewController(animated: true)
                    
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    func callDeleteAPI() {
        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
            }
            showAlert(title: "No Internet Connection", message: "Make sure your device is connected to the internet.")
        }
        else {
            
            SVProgressHUD.show()
            let userDefaults = UserDefaults.standard
            do {
                let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                
                let baseURL = Constants.baseProductionURL + "deleteUserOtp"
                
                let headers = ["Content-Type" : "application/json",
                               "Authorization" : "Bearer " + (userDetail.token ?? "")]
                
                let request = NSMutableURLRequest(url: URL(string: baseURL)!)
                //                let request = NSMutableURLRequest(url: baseURL)
                
                let config = URLSessionConfiguration.default
                config.httpAdditionalHeaders = headers
                request.httpMethod = "GET"
                let session = URLSession(configuration: config)
                
                //                print("Resources Detail Endpoint :: \(url)")
                print("Req :: \(request)")
                
                let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                    
                    // Check if Error took place
                    if let error = error {
                        print("Error took place \(error)")
                        return
                    }
                    
                    // Read HTTP Response Status code
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                    }
                    SVProgressHUD.dismiss()
                    if let data = data {
                        do {
                            let res = try JSONDecoder().decode(LogoutDataModel.self, from: data)
                            print("--- Entering Response ---")
                            let responseString = String(data: data , encoding: .utf8) ?? ""
                            print("Response :: \(responseString)")
                            DispatchQueue.main.async {
                                self.enterOTPMainVw.isHidden = false
                                self.startTimer()
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func validateDeleteOtp(otp: Int) {
        if !isConnectionAvailable() {
            if NetWorker.isShowNoInternet {
                NetWorker.isShowNoInternet = false
            }
            showAlert(title: "No Internet Connection", message: "Make sure your device is connected to the internet.")
            return
        }

        SVProgressHUD.show()

        let userDefault = UserDefaults.standard
        do {
            let userDetail = try userDefault.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)

            let baseURL = Constants.baseProductionURL + "deleteUser"

            let headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer " + (userDetail.token ?? "")
            ]

            // Create URL Request
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers

            // Create JSON body
            let requestBody: [String: Any] = ["otp": otp]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

            // Start URLSession
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                }

                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(LogoutDataModel.self, from: data)
                        if (res.success ?? false) {
                            DispatchQueue.main.async {
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            UserDefaults.standard.synchronize()
                            userDefaults.isGuestLogin = true
                            userDefaults.type = 0
                            //self?.navigationController?.popToRootViewController(animated: true)
                            let vc = HomeTabBarVC.instantiate()
                            guard let navigationController = self.navigationController else { return }
                            var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
                            navigationArray.removeAll()
                            navigationArray.append(vc) //To remove all previous UIViewController and append the sign in view controller in navigation stack
                            self.navigationController?.viewControllers = navigationArray
                            self.navigationController?.popViewController(animated: true)
                                
                            }
                        } else {
                            self.showAlert(title: "Failure", message: "\(res.message ?? "Error")")
                        }
                        print("Response: \(res)")
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error retrieving user details: \(error.localizedDescription)")
        }
    }
}

extension ProfileViewController : DPOTPViewDelegate {
   func dpOTPViewAddText(_ text: String, at position: Int) {
       //print("addText:- " + text + " at:- \(position)" )
       if text.count == 6 {
           self.enterOtpContinueBtnEnable()
       } else {
           self.enterOtpContinueBtnDisable()
       }
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        //print("removeText:- " + text + " at:- \(position)" )
        if text.count == 6 {
            self.enterOtpContinueBtnEnable()
        } else {
            self.enterOtpContinueBtnDisable()
        }
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        //print("at:-\(position)")
    }
    func dpOTPViewBecomeFirstResponder() {
        //print("First Become First Responder")
    }
    func dpOTPViewResignFirstResponder() {
        //print("First Resign First Responder")
    }
}

//MARK: Custom functions
extension ProfileViewController {
    
    func setupEnterOtpVw() {
        self.enterOTPMainVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        self.otpView.keyboardType = .numberPad
        self.otpView.text = ""

        self.otpTitleLbl.text = "Please enter the 6 digit verification code send to \(self.userEmail)"

        let labelAttriString = NSMutableAttributedString(string: self.otpTitleLbl.text!)
        let range1 = (self.otpTitleLbl.text! as NSString).range(of: "Please enter the 6 digit verification code send to")
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14), range: range1)
        self.otpTitleLbl.attributedText = labelAttriString

        //Resend Button Disable...
        self.resendOTPBtn.isUserInteractionEnabled = false
        self.resendOTPBtn.setTitle("Resend OTP in", for: .normal)
        self.resendOTPBtn.setTitleColor(UIColor(hex: "#8A8E88", alpha: 1.0), for: .normal)
        
        self.enterOTPContinueBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
        self.enterOTPContinueBtn.isUserInteractionEnabled = true
        self.enterOTPContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    func startTimer() {
        timerLbl.isHidden = true
        timerLbl.text = ""
        totalSecond = 20
        
        //Resend Button Disable...
        self.resendOTPBtn.isUserInteractionEnabled = false
        self.resendOTPBtn.setTitle("Resend OTP in", for: .normal)
        self.resendOTPBtn.setTitleColor(UIColor(hex: "#8A8E88", alpha: 1.0), for: .normal)

        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timerLbl.isHidden = true
        self.timerLbl.text = ""
        timer?.invalidate()
        timer = nil
    }
    
    @objc func countdown() {
        //print("Time- ",totalSecond)
        if totalSecond == 0 {
            timer?.invalidate()
            timer = nil
            self.timerLbl.isHidden = true
            self.timerLbl.text = ""
            
            //Resend Button Enable...
            self.resendOTPBtn.isUserInteractionEnabled = true
            self.resendOTPBtn.setTitle("Resend OTP", for: .normal)
            self.resendOTPBtn.setTitleColor(UIColor.black, for: .normal)
        }
        else {
            minutes = (totalSecond / 60)
            seconds = (totalSecond % 3600) % 60
            self.timerLbl.isHidden = false
            self.timerLbl.text = String(format: "%02d:%02d", minutes, seconds) //00:10
            totalSecond = totalSecond - 1
        }
    }
    
    func enterOtpContinueBtnEnable() {
        self.enterOTPContinueBtn.isUserInteractionEnabled = true
        self.enterOTPContinueBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func enterOtpContinueBtnDisable() {
        self.enterOTPContinueBtn.isUserInteractionEnabled = false
        self.enterOTPContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
}

extension ProfileViewController: OpenAllOrderDelegate {
    func openAllOrderFromHelp() {
        let vc = MyOrderVC.instantiate(preOrderApi: PreOrderAPI())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.accountSettingCollectionVw:
            return self.titleListArr.count
                        
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.accountSettingCollectionVw:
            let cell = accountSettingCollectionVw.dequeueReusableCell(withReuseIdentifier: AccountSettingCVC.identifier, for: indexPath) as! AccountSettingCVC
            
            cell.titleLbl.text = self.titleListArr[indexPath.row]
            cell.iconImgVw.image = UIImage(named: self.imgListArr[indexPath.row])
            
            if indexPath.row == 3 || indexPath.row == 4 {
                cell.leftArrowImgVw.isHidden = true
            } else {
                cell.leftArrowImgVw.isHidden = false
            }
            
            if indexPath.row == 4 {
                cell.titleLbl.textColor = UIColor.init(hex: "#EE3F37", alpha: 1.0)
            }
            
            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case accountSettingCollectionVw:
            let width = (self.accountSettingCollectionVw.frame.size.width)
            if Constants.Is_iPad {
                return CGSize(width: width, height: 70.0)
            } else {
                return CGSize(width: width, height: 50.0)
            }
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case accountSettingCollectionVw:

            if (indexPath.row == 0) { //Edit Profile....
                let vc = EditProfileVC.instantiate(profileApi: ProfileAPI(), editProfileApi: EditProfileAPI(), changeProfileImageApi: ChangeProfileImageAPI())
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if (indexPath.row == 1) { //Saved Address....
                let vc = ShippingAddressVC.instantiate(addressListApi: AddressListAPI(), deleteAddressApi: DeleteAddressAPI(),addAddressApi: AddAddressAPI())
                vc.isComeFromProfilePage = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if (indexPath.row == 2) { //Notification Setting....
                let vc = NotificationSettingVC.instantiate(notificationSettingsApi:NotificationSettingAPI())
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if (indexPath.row == 3) { //Logout....
                self.logoutPopupBaseVw.isHidden = false
            }
            else if (indexPath.row == 4) { //Delete....
                self.deletePopupBaseVw.isHidden = false
            }
            
        default:
            break
        }
    }
}

// MARK: - Logout API Protocol
protocol LogoutAPIProtocol {
    func getData(completion: @escaping ((LogoutDataModel?) -> Void))
}

struct LogoutAPI: LogoutAPIProtocol {
    func getData(completion: @escaping ((LogoutDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .logout) { (data: LogoutDataModel?) in
            completion(data)
        }
    }
}
