//
//  LoginVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/02/24.
//

import UIKit
import AVKit
import AVFoundation
import SVProgressHUD
import FreshchatSDK

class LoginVC: UIViewController, XIBed {
    
    static func instantiate(loginApi: LoginAPIProtocol, signupApi: SignupAPIProtocol, sendOtpApi: SendOtpAPIProtocol, verifyOtpApi: VerifyOtpAPIProtocol, resetPwApi:ResetPwAPIProtocol, guestLoginApi:GuestLoginAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.loginApi = loginApi
        vc.signupApi = signupApi
        vc.sendOtpApi = sendOtpApi
        vc.verifyOtpApi = verifyOtpApi
        vc.resetPwApi = resetPwApi
        vc.guestLoginApi = guestLoginApi
        return vc
    }
    
    var loginApi: LoginAPIProtocol?
    var signupApi: SignupAPIProtocol?
    var sendOtpApi: SendOtpAPIProtocol?
    var verifyOtpApi: VerifyOtpAPIProtocol?
    var resetPwApi: ResetPwAPIProtocol?
    var guestLoginApi: GuestLoginAPIProtocol?
    
    
    var guestLoginDetails: GuestLoginDataResult?
    var signupResult: SignupDataResult?
    
    @IBOutlet weak var videoPlayerBaseVw: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer?

    @IBOutlet weak var loginBaseVw: UIView!
    @IBOutlet weak var loginMailVw: UIView!
    @IBOutlet weak var loginEmailTxtField: UITextField!
    @IBOutlet weak var loginPwVw: UIView!
    @IBOutlet weak var loginPwTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var guestBtn: UIButton!
    
    @IBOutlet weak var createAccountBaseVw: UIView!
    @IBOutlet weak var createMailVw: UIView!
    @IBOutlet weak var createMailTxtField: UITextField!
    @IBOutlet weak var createPwVw: UIView!
    @IBOutlet weak var createPwTxtField: UITextField!
    @IBOutlet weak var confirmPwVw: UIView!
    @IBOutlet weak var confirmPwTxtField: UITextField!
    @IBOutlet weak var createAcBtn: UIButton!
    @IBOutlet weak var createGuestBtn: UIButton!
    @IBOutlet weak var exitingLabel: UILabel!
    
    @IBOutlet weak var forgotPwMainVw: UIView!
    @IBOutlet weak var forgotPwBaseVw: UIView!
    @IBOutlet weak var forgotPwMailVw: UIView!
    @IBOutlet weak var forgotPwMailTxtField: UITextField!
    @IBOutlet weak var forgotPwContinueBtn: UIButton!
    
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

    @IBOutlet weak var newPasswordMainVw: UIView!
    @IBOutlet weak var newPwVw: UIView!
    @IBOutlet weak var newPwtxtField: UITextField!
    @IBOutlet weak var confirmNewPwVw: UIView!
    @IBOutlet weak var confirmNewPwTxtField: UITextField!
    @IBOutlet weak var newPwContinueBtn: UIButton!
    @IBOutlet weak var newPwEditMailLbl: UILabel!
    
    var isComeFromCart = false
    var isCreateAccount = false
    var isForgotPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBaseVw.isHidden = true
        self.createAccountBaseVw.isHidden = true
        self.forgotPwMainVw.isHidden = true
        self.enterOTPMainVw.isHidden = true
        self.newPasswordMainVw.isHidden = true

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isComeFromCart = false
        self.isCreateAccount = false
        self.isForgotPassword = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoBg()
    }
    
    func setupVideoBg(){
        let videoURL: NSURL = Bundle.main.url(forResource: "sample_video", withExtension: "mp4")! as NSURL
        
        player = AVPlayer(url: videoURL as URL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer?.zPosition = -1
        playerLayer?.frame = videoPlayerBaseVw.layer.bounds

        videoPlayerBaseVw.layer.addSublayer(playerLayer!)
        player?.play()
        
        //loop video
        NotificationCenter.default.addObserver(self, selector: #selector(self.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update playerLayer frame when layout changes
        playerLayer?.frame = videoPlayerBaseVw.bounds
    }
    
    @objc func loopVideo() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }

    func setupUI() {
        self.loginEmailTxtField.text = ""
        self.loginPwTxtField.text = ""
        self.loginBaseVw.isHidden = true
        self.createAccountBaseVw.isHidden = true
        self.forgotPwMainVw.isHidden = true
        self.forgotPwBaseVw.isHidden = true
        self.enterOTPMainVw.isHidden = true
        self.newPasswordMainVw.isHidden = true
        
        setupLoginVw()
        setupCreateAccountVw()
        setupForgotPasswordVw()
        setupEnterOtpVw()
        setupNewPwVw()
        self.loginBaseVw.isHidden = false
        loginBtnDisable()
        
        self.otpView.dpOTPViewDelegate = self
        
        self.loginEmailTxtField.delegate = self
        self.loginEmailTxtField.addTarget(self, action: #selector(self.loginEmailTxtFieldDidChange(_:)), for: .editingChanged)
        self.loginPwTxtField.delegate = self
        self.loginPwTxtField.addTarget(self, action: #selector(self.loginPwTxtFieldDidChange(_:)), for: .editingChanged)
        self.createMailTxtField.delegate = self
        self.createMailTxtField.addTarget(self, action: #selector(self.createMailTxtFieldDidChange(_:)), for: .editingChanged)
        self.createPwTxtField.delegate = self
        self.createPwTxtField.addTarget(self, action: #selector(self.createPwTxtFieldDidChange(_:)), for: .editingChanged)
        self.confirmPwTxtField.delegate = self
        self.confirmPwTxtField.addTarget(self, action: #selector(self.confirmPwTxtFieldDidChange(_:)), for: .editingChanged)
        self.newPwtxtField.delegate = self
        self.newPwtxtField.addTarget(self, action: #selector(self.newPwtxtFieldDidChange(_:)), for: .editingChanged)
        self.confirmNewPwTxtField.delegate = self
        self.confirmNewPwTxtField.addTarget(self, action: #selector(self.confirmNewPwTxtFieldDidChange(_:)), for: .editingChanged)
        self.forgotPwMailTxtField.delegate = self
        self.forgotPwMailTxtField.addTarget(self, action: #selector(self.forgotPwMailTxtFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupLoginVw() {
        self.loginBaseVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        self.loginMailVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.loginMailVw.layer.borderWidth = 1.0
        self.loginMailVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        self.loginPwVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.loginPwVw.layer.borderWidth = 1.0
        self.loginPwVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        
        self.loginBtn.layer.cornerRadius = Constants.Is_iPad ? 28.0 : 22.0
        
        self.createAccountBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
        self.createAccountBtn.layer.borderWidth = 1.0
        self.createAccountBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        
        self.guestBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
        self.guestBtn.layer.borderWidth = 1.0
        self.guestBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor

        self.loginPwTxtField.isSecureTextEntry = true
        
        
        self.enterOtpEditMailLbl.text = "Wrong email address? Edit"
        let labelAttriString = NSMutableAttributedString(string: self.enterOtpEditMailLbl.text!)
        let range = (self.enterOtpEditMailLbl.text! as NSString).range(of: "Edit")
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16), range: range)
        labelAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#0050FF", alpha: 1.0) as UIColor, range: range)

        self.enterOtpEditMailLbl.attributedText = labelAttriString
        let tap = UITapGestureRecognizer(target: self, action: #selector(enterOtpEditMailTap(tap:)))
        self.enterOtpEditMailLbl.addGestureRecognizer(tap)
        self.enterOtpEditMailLbl.isUserInteractionEnabled = true

        self.newPwEditMailLbl.text = "Wrong email address? Edit"
        let labelAttriString1 = NSMutableAttributedString(string: self.newPwEditMailLbl.text!)
        let range1 = (self.newPwEditMailLbl.text! as NSString).range(of: "Edit")
        labelAttriString1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16), range: range1)
        labelAttriString1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#0050FF", alpha: 1.0) as UIColor, range: range1)

        self.newPwEditMailLbl.attributedText = labelAttriString1
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(newPwEditMailTap(tap:)))
        self.newPwEditMailLbl.addGestureRecognizer(tap1)
        self.newPwEditMailLbl.isUserInteractionEnabled = true
    }
    
    @objc func enterOtpEditMailTap(tap: UITapGestureRecognizer) {
        let loginText = (self.enterOtpEditMailLbl.text! as NSString).range(of: "Edit")
        if tap.didTapAttributedTextInLabel(label: self.enterOtpEditMailLbl, inRange: loginText) {
            print("Enter OTP Edit tapped.")
            
            self.enterOTPMainVw.isHidden = true
            if self.isCreateAccount {
                self.createAccountBaseVw.isHidden = false
            } else {
                self.forgotPwMainVw.isHidden = false
                self.forgotPwBaseVw.isHidden = false
            }
        } else {
            print("Other Tapped")
        }
    }

    @objc func newPwEditMailTap(tap: UITapGestureRecognizer) {
        let loginText = (self.newPwEditMailLbl.text! as NSString).range(of: "Edit")
        if tap.didTapAttributedTextInLabel(label: self.newPwEditMailLbl, inRange: loginText) {
            print("New Password Edit tapped.")
            self.newPasswordMainVw.isHidden = true
            self.forgotPwMainVw.isHidden = false
            self.forgotPwBaseVw.isHidden = false
        } else {
            print("Other Tapped")
        }
    }

    
    func setupCreateAccountVw() {
        self.createAccountBaseVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        self.createMailVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.createMailVw.layer.borderWidth = 1.0
        self.createMailVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        self.createPwVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.createPwVw.layer.borderWidth = 1.0
        self.createPwVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        self.confirmPwVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.confirmPwVw.layer.borderWidth = 1.0
        self.confirmPwVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor

        self.createAcBtn.layer.cornerRadius = Constants.Is_iPad ? 28.0 : 22.0
        self.createGuestBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
        self.createGuestBtn.layer.borderWidth = 1.0
        self.createGuestBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor

        self.createPwTxtField.isSecureTextEntry = true
        self.confirmPwTxtField.isSecureTextEntry = true
        
        self.exitingLabel.text = "Existing Customer? Log in"
        
        let labelAttriString = NSMutableAttributedString(string: self.exitingLabel.text!)
        let range1 = (self.exitingLabel.text! as NSString).range(of: "Log in")
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16), range: range1)
        labelAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#008BBF", alpha: 1.0) as UIColor, range: range1)

        self.exitingLabel.attributedText = labelAttriString
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        self.exitingLabel.addGestureRecognizer(tap)
        self.exitingLabel.isUserInteractionEnabled = true
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        let loginText = (self.exitingLabel.text! as NSString).range(of: "Log in")
        if tap.didTapAttributedTextInLabel(label: self.exitingLabel, inRange: loginText) {
            print("Log In tapped.")
            self.loginBaseVw.isHidden = false
            self.createAccountBaseVw.isHidden = true
            self.loginEmailTxtField.text = ""
            self.loginPwTxtField.text = ""
        } else {
            print("Other Tapped")
        }
    }
    
    
    func setupForgotPasswordVw() {
        self.forgotPwBaseVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        self.forgotPwMailVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.forgotPwMailVw.layer.borderWidth = 1.0
        self.forgotPwMailVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        self.forgotPwContinueBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
    }
    
    func setupEnterOtpVw() {
        self.enterOTPMainVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        self.otpView.keyboardType = .numberPad
        self.otpView.text = ""
        
        if self.isCreateAccount {
            self.otpTitleLbl.text = "Please enter the 6 digit verification code send to \(self.createMailTxtField.text!)"
        } else {
            self.otpTitleLbl.text = "Please enter the 6 digit verification code send to \(self.forgotPwMailTxtField.text!)"
        }
        
        let labelAttriString = NSMutableAttributedString(string: self.otpTitleLbl.text!)
        let range1 = (self.otpTitleLbl.text! as NSString).range(of: "Please enter the 6 digit verification code send to")
        labelAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Poppins-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14), range: range1)
        self.otpTitleLbl.attributedText = labelAttriString

        self.enterOTPContinueBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
        //Resend Button Disable...
        self.resendOTPBtn.isUserInteractionEnabled = false
        self.resendOTPBtn.setTitle("Resend OTP in", for: .normal)
        self.resendOTPBtn.setTitleColor(UIColor(hex: "#8A8E88", alpha: 1.0), for: .normal)
    }
    
    func setupNewPwVw() {
        self.newPasswordMainVw.layer.cornerRadius = Constants.Is_iPad ? 26.0 : 20.0
        
        self.newPwVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.newPwVw.layer.borderWidth = 1.0
        self.newPwVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor
        self.confirmNewPwVw.layer.cornerRadius = Constants.Is_iPad ? 18.0 : 12.0
        self.confirmNewPwVw.layer.borderWidth = 1.0
        self.confirmNewPwVw.layer.borderColor = UIColor(hex: "#000000", alpha: 0.20).cgColor

        self.newPwContinueBtn.layer.cornerRadius = Constants.Is_iPad ? 27.0 : 21.0
    }
    
    @IBAction func onLoginPwEyeBtnTap(_ sender: UIButton) {
        if self.loginPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.loginPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.loginPwTxtField.isSecureTextEntry = true
        }
    }
    
    func openDashboard() {
        userDefaults.type = 0
        let vc = HomeTabBarVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Login Button Action...
    @IBAction func onLoginBtnTapped(_ sender: UIButton) {
        print("Login")
        if loginValidation() {
            fetchLoginData()
        }
    }
    
    func loginValidation() -> Bool {
        if self.loginEmailTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter e-mail address")
            return false
        }
        else if self.loginPwTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Enter Password.")
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func onForgotPwBtnTap(_ sender: UIButton) {
        print("Forgot Password...")
        self.forgotPwMailTxtField.text = ""
        self.isForgotPassword = true
        self.isCreateAccount = false
        self.loginBaseVw.isHidden = true
        self.forgotPwMainVw.isHidden = false
        self.forgotPwBaseVw.isHidden = false
        self.forgotPwContinueBtnDisable()
        //self.enterOtpContinueBtnDisable()
    }
    
    
    @IBAction func onCreateAccountBtnTapped(_ sender: UIButton) {
        print("Create Account")
        self.loginBaseVw.isHidden = true
        self.createAccountBaseVw.isHidden = false
        self.forgotPwBaseVw.isHidden = true
        self.enterOTPMainVw.isHidden = true
        self.newPasswordMainVw.isHidden = true
        
        self.isCreateAccount = true
        self.isForgotPassword = false
        self.createAccountBtnDisable()
        self.createMailTxtField.text = ""
        self.createPwTxtField.text = ""
        self.confirmPwTxtField.text = ""
    }
    
    @IBAction func onProceedAsGuestBtnTapped(_ sender: UIButton) {
        print("Proceed as Guest")
        if userDefaults.isGuestLogin {
            print("Guest Login...")
            openDashboard()
        } else {
            guestLoginApiCall()
        }
    }

    
    //MARK: Create Account Action...
    @IBAction func onCreatePwEyeBtnTap(_ sender: UIButton) {
        if self.createPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.createPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.createPwTxtField.isSecureTextEntry = true
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
    
    func signUpValidation() -> Bool {
        if self.createMailTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Please enter e-mail address")
            return false
        }
        else if !self.createMailTxtField.text!.isValidEmail {
            showAlert(title: "Alert", message: "Please enter valid e-mail address")
            return false
        }
        else if self.createPwTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Please enter password")
            return false
        }
        else if !isPasswordValid(self.createPwTxtField.text!) {
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
        else if !self.createPwTxtField.text!.elementsEqual(self.confirmPwTxtField.text!) {
            showAlert(title: "Alert", message: "Please enter both password same")
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func onFinalCreateBtnTap(_ sender: UIButton) {
        print("Final Create Account...")
        if signUpValidation() {
            userDefaults.isGuestLogin = false
            Constants.isGuestLogin = userDefaults.isGuestLogin
            SVProgressHUD.show()
            DispatchQueue.main.async {
                self.signupApiCall()
            }
        }
    }
    
    //MARK: Forgot Password Action...
    @IBAction func onForgotPwBackBtnTap(_ sender: UIButton) {
        print("Forgot Password Back...")
        self.forgotPwMailTxtField.text = ""
        self.loginEmailTxtField.text = ""
        self.loginPwTxtField.text = ""
        self.loginBaseVw.isHidden = false
        self.forgotPwMainVw.isHidden = true
        self.forgotPwBaseVw.isHidden = true
        loginBtnDisable()
    }
    
    @IBAction func onForgotPwContinueBtnTap(_ sender: UIButton) {
        print("Forgot Password Continue...")
        
        if self.forgotPwMailTxtField.text!.elementsEqual("") {
            showAlert(title: "Alert", message: "Please enter email address.")
        } else {
            SVProgressHUD.show()
            DispatchQueue.main.async {
                self.sendOtpApiCall(email: self.forgotPwMailTxtField.text ?? "")
            }
        }
    }
    
    //MARK: Enter OTP Action...
    @IBAction func onEnterOtpContinueBtnTap(_ sender: UIButton) {
        print("Enter OTP Continue...")
        
        self.stopTimer()
        if self.isCreateAccount {
            fetchOtpVerifyData(email: self.createMailTxtField.text ?? "")
        }
        else {
            fetchOtpVerifyData(email: self.forgotPwMailTxtField.text ?? "")
        }
    }
    
    @IBAction func onResendOtpBtnTap(_ sender: UIButton) {
        print("Resend OTP Tap...")
        if self.isCreateAccount {
            SVProgressHUD.show()
            DispatchQueue.main.async {
                self.sendOtpApiCall(email: self.createMailTxtField.text ?? "")
            }
        } else {
            if self.forgotPwMailTxtField.text!.elementsEqual("") {
                showAlert(title: "Alert", message: "Please enter email address.")
            } else {
                SVProgressHUD.show()
                DispatchQueue.main.async {
                    self.sendOtpApiCall(email: self.forgotPwMailTxtField.text ?? "")
                }
            }
        }
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

    //MARK: New Password Action...
    @IBAction func onNewPwContinueBtnTap(_ sender: UIButton) {
        print("New Password Continue...")
        if self.newPwtxtField.text!.elementsEqual(self.confirmNewPwTxtField.text!) {
            resetPasswordApiCall()
        } else {
            showAlert(title: "Alert", message: "Please enter same password")
        }
    }
    
    @IBAction func onNewPwPwEyeBtnTap(_ sender: UIButton) {
        if self.newPwtxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.newPwtxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.newPwtxtField.isSecureTextEntry = true
        }
    }
    
    @IBAction func onConfirmNewPwPwEyeBtnTap(_ sender: UIButton) {
        if self.confirmNewPwTxtField.isSecureTextEntry == true {
            sender.setImage(UIImage(named: "Eye_Show"), for: .normal)
            self.confirmNewPwTxtField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "Eye_Hide"), for: .normal)
            self.confirmNewPwTxtField.isSecureTextEntry = true
        }
    }

    func fetchLoginData() {
        let email = self.loginEmailTxtField.text ?? ""
        let password = self.loginPwTxtField.text ?? ""
        let guest_session_id = userDefaults.guestTokenID
        
        loginApi?.getData(email: email, password: password, guest_session_id: guest_session_id, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                userDefaults.isGuestLogin = false
                userDefaults.isLogin = true
                Constants.isGuestLogin = userDefaults.isGuestLogin
                
                //==> Save model data in userdefaults...
                let details = response.data
                let userDetail = UserDetails(token: details?.token ?? "", fullName: details?.fullname ?? "", mobileNo: details?.mobile ?? "", email: details?.email ?? "", dob: details?.dob ?? "", userID: details?.id ?? 0)
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.setObject(userDetail, forKey: "UserDetailsData")
                } catch {
                    print(error.localizedDescription)
                }
                self?.openDashboard()
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func signupApiCall() {
        let email = self.createMailTxtField.text ?? ""
        let password = self.createPwTxtField.text ?? ""
        let deviceToken = userDefaults.accessToken // "ckk32A0sQ9S8lUhc8Sbr3I%3AAPA91bHaUELAJRIn7OuhuKDzgSYKzcsD0089werWlJ3MyJWdz6-dHJff6TGNnklbXzsNAAV9V55j1HNN3heQg1Q2hibzLh7n9Y_Lf7M7yNCz7LQT8tl45EwI16gh5FrC7XNoZ-5W3x09"
        let guest_session_id = userDefaults.guestTokenID
        
        signupApi?.getData(email: email, password: password, deviceToken: deviceToken, guest_session_id: guest_session_id, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                SVProgressHUD.show()
                self?.signupResult = response.data
                DispatchQueue.main.async {
                    self?.sendOtpApiCall(email: self?.createMailTxtField.text ?? "")
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func sendOtpApiCall(email: String) {
        var requestPlace = ""
        if self.isCreateAccount {
            requestPlace = "mobile_register"
        } else {
            requestPlace = "web"
        }
        
        sendOtpApi?.getData(email: email, requestPlace: requestPlace, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                //==> open OTP View....
                
                if self!.isForgotPassword {
                    self?.forgotPwMainVw.isHidden = true
                    self?.forgotPwBaseVw.isHidden = true
                    self?.loginBaseVw.isHidden = true
                    self?.createAccountBaseVw.isHidden = true
                    self?.newPasswordMainVw.isHidden = true
                }
                else {
                    self?.isCreateAccount = true
                    self?.isForgotPassword = false
                    self?.createAccountBaseVw.isHidden = true
                }
                self?.enterOTPMainVw.isHidden = false
                self?.setupEnterOtpVw()
                self?.startTimer()
                self?.enterOtpContinueBtnDisable()
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func fetchOtpVerifyData(email: String) {
        var noRegister = 0
        if self.isCreateAccount {
            noRegister = 1
        } else { //Forgot password...
            noRegister = 0
        }
        
        verifyOtpApi?.getData(email: email, otp: self.otpView.text ?? "", noRegister: noRegister, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                userDefaults.unique_Id = response.uniqueID ?? ""
                
                if self!.isForgotPassword {
                    self?.newPwtxtField.text = ""
                    self?.confirmNewPwTxtField.text = ""
                    self?.newPwtxtField.isSecureTextEntry = true
                    self?.confirmNewPwTxtField.isSecureTextEntry = true
                    
                    self?.forgotPwMainVw.isHidden = true
                    self?.forgotPwBaseVw.isHidden = true
                    self?.loginBaseVw.isHidden = true
                    self?.createAccountBaseVw.isHidden = true
                    self?.enterOTPMainVw.isHidden = true
                    self?.newPasswordMainVw.isHidden = false
                    self?.newPwContinueBtnDisable()
                }
                else {
                    self?.enterOTPMainVw.isHidden = true
                    self?.isCreateAccount = false
                    
                    //==> Save model data in userdefaults...
                    let details = self?.signupResult
                    let userDetail = UserDetails(token: details?.token ?? "", fullName: details?.fullname ?? "", mobileNo: details?.mobile ?? "", email: details?.email ?? "", dob: details?.dob ?? "", userID: details?.id ?? 0)
                    let userDefault = UserDefaults.standard
                    do {
                        try userDefault.setObject(userDetail, forKey: "UserDetailsData")
                    } catch {
                        print(error.localizedDescription)
                    }

                    userDefaults.isLogin = true
                    self?.openDashboard()
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func resetPasswordApiCall() {
        let email = self.forgotPwMailTxtField.text ?? ""
        let password = self.newPwtxtField.text ?? ""
        let cPassword = self.confirmNewPwTxtField.text ?? ""
        let uniqueId = userDefaults.unique_Id
        
        resetPwApi?.getData(password: password, cpassword: cPassword, email: email, unique_id: uniqueId, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                let alertController = UIAlertController(title: "Success", message: response.message ?? "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { success in
                    userDefaults.isGuestLogin = false
                    Constants.isGuestLogin = userDefaults.isGuestLogin
                    self?.setupUI()
                }
                alertController.addAction(okAction)
                self?.present(alertController, animated: true, completion: nil)
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func guestLoginApiCall() {
        guestLoginApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.guestLoginDetails = response.data
                userDefaults.isGuestLogin = true
                Constants.isGuestLogin = userDefaults.isGuestLogin
                
                //==> Save model data in userdefaults...
                let details = response.data
                //Save for Login...
                userDefaults.guestTokenID = details?.tokenId ?? ""
                userDefaults.accessToken = details?.token ?? ""
                let userDetail = UserDetails(token: details?.token ?? "", fullName: details?.fullname ?? "", mobileNo: details?.mobile ?? "", email: details?.email ?? "", dob: details?.dob ?? "", userID: details?.id ?? 0)
                
                let userDefault = UserDefaults.standard
                do {
                    try userDefault.setObject(userDetail, forKey: "UserDetailsData")
                } catch {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self?.setupUI()
                }
                userDefaults.type = 0
                self?.openDashboard()
            } else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
}

//Button Enable Disable...
extension LoginVC {
    func loginBtnEnable() {
        self.loginBtn.isUserInteractionEnabled = true
        self.loginBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func loginBtnDisable() {
        self.loginBtn.isUserInteractionEnabled = false
        self.loginBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    func createAccountBtnEnable() {
        self.createAcBtn.isUserInteractionEnabled = true
        self.createAcBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func createAccountBtnDisable() {
        self.createAcBtn.isUserInteractionEnabled = false
        self.createAcBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    func enterOtpContinueBtnEnable() {
        self.enterOTPContinueBtn.isUserInteractionEnabled = true
        self.enterOTPContinueBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func enterOtpContinueBtnDisable() {
        self.enterOTPContinueBtn.isUserInteractionEnabled = false
        self.enterOTPContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    func newPwContinueBtnEnable() {
        self.newPwContinueBtn.isUserInteractionEnabled = true
        self.newPwContinueBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func newPwContinueBtnDisable() {
        self.newPwContinueBtn.isUserInteractionEnabled = false
        self.newPwContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    func forgotPwContinueBtnEnable() {
        self.forgotPwContinueBtn.isUserInteractionEnabled = true
        self.forgotPwContinueBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func forgotPwContinueBtnDisable() {
        self.forgotPwContinueBtn.isUserInteractionEnabled = false
        self.forgotPwContinueBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
}


//MARK: TextField Delegate.....
extension LoginVC: UITextFieldDelegate {
    @objc func loginEmailTxtFieldDidChange(_ textField: UITextField) {
        loginBtnUpdate()
    }
    
    @objc func loginPwTxtFieldDidChange(_ textField: UITextField) {
        loginBtnUpdate()
    }

    func loginBtnUpdate() {
        if (self.loginEmailTxtField.text!.isValidEmail) && (self.loginPwTxtField.text?.count ?? 0) >= 8 {
            self.loginBtnEnable()
        }else {
            self.loginBtnDisable()
        }
    }
    
    @objc func createMailTxtFieldDidChange(_ textField: UITextField) {
        createButtonUpdate()
    }
    
    @objc func createPwTxtFieldDidChange(_ textField: UITextField) {
        createButtonUpdate()
    }
    
    @objc func confirmPwTxtFieldDidChange(_ textField: UITextField) {
        createButtonUpdate()
    }
    
    func createButtonUpdate() {
        if (self.createMailTxtField.text!.isValidEmail) && (self.createPwTxtField.text?.count ?? 0) >= 8 && (self.confirmPwTxtField.text?.count ?? 0) >= 8 {
            self.createAccountBtnEnable()
        }else {
            self.createAccountBtnDisable()
        }
    }
    
    @objc func newPwtxtFieldDidChange(_ textField: UITextField) {
        newPwContinueBtnUpdate()
    }
    
    @objc func confirmNewPwTxtFieldDidChange(_ textField: UITextField) {
        newPwContinueBtnUpdate()
    }

    func newPwContinueBtnUpdate() {
        if (self.newPwtxtField.text?.count ?? 0) >= 8 && (self.confirmNewPwTxtField.text?.count ?? 0) >= 8 {
            self.newPwContinueBtnEnable()
        }else {
            self.newPwContinueBtnDisable()
        }
    }
    
    @objc func forgotPwMailTxtFieldDidChange(_ textField: UITextField) {
        if (self.forgotPwMailTxtField.text!.isValidEmail){
            self.forgotPwContinueBtnEnable()
        } else {
            self.forgotPwContinueBtnDisable()
        }
    }
}

extension LoginVC : DPOTPViewDelegate {
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


// MARK: - Login API Protocol
protocol LoginAPIProtocol {
    func getData(email: String, password: String, guest_session_id: String, completion: @escaping ((LoginDataModel?) -> Void))
}

struct LoginAPI: LoginAPIProtocol {
    func getData(email: String, password: String, guest_session_id: String, completion: @escaping ((LoginDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .login(email: email, password: password, guest_session_id: guest_session_id)) { (data: LoginDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Login API Protocol
protocol SignupAPIProtocol {
    func getData(email: String, password: String, deviceToken: String, guest_session_id: String, completion: @escaping ((SignupDataModel?) -> Void))
}

struct SignUPAPI: SignupAPIProtocol {
    func getData(email: String, password: String, deviceToken: String, guest_session_id: String, completion: @escaping ((SignupDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .signUp(email: email, password: password, deviceToken: deviceToken, guest_session_id: guest_session_id)) {(data: SignupDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Send OTP API Protocol
protocol SendOtpAPIProtocol {
    func getData(email: String, requestPlace: String, completion: @escaping ((SendOtpModel?) -> Void))
}

struct SendOtpAPI: SendOtpAPIProtocol {
    func getData(email: String, requestPlace: String, completion: @escaping ((SendOtpModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .sendOTP(email: email, requestPlace: requestPlace)) { (data: SendOtpModel?) in
            completion(data)
        }
    }
}

// MARK: - Verify OTP API Protocol
protocol VerifyOtpAPIProtocol {
    func getData(email: String, otp: String, noRegister: Int, completion: @escaping ((VerifyOtpModel?) -> Void))
}

struct VerifyOtpAPI: VerifyOtpAPIProtocol {
    func getData(email: String, otp: String, noRegister: Int, completion: @escaping ((VerifyOtpModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .verifyOTP(email: email, otp: otp, noRegister: noRegister)) { (data: VerifyOtpModel?) in
            completion(data)
        }
    }
}

// MARK: - Reset Password API Protocol
protocol ResetPwAPIProtocol {
    func getData(password: String, cpassword: String, email: String, unique_id: String, completion: @escaping ((ResetPwModel?) -> Void))
}

struct ResetPwAPI: ResetPwAPIProtocol {
    func getData(password: String, cpassword: String, email: String, unique_id: String, completion: @escaping ((ResetPwModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .resetPassword(password: password, cpassword: cpassword, email: email, unique_id: unique_id)) { (data: ResetPwModel?) in
            completion(data)
        }
    }
}

// MARK: - Guest Login API Protocol
protocol GuestLoginAPIProtocol {
    func getData(completion: @escaping ((GuestLoginDataModel?) -> Void))
}

struct GuestLoginAPI: GuestLoginAPIProtocol {
    func getData(completion: @escaping ((GuestLoginDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .guestLogin) { (data: GuestLoginDataModel?) in
            completion(data)
        }
    }
}
