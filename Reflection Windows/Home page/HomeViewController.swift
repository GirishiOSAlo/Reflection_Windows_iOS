//
//  HomeViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/02/24.
//

import UIKit
import moa
import AVKit
import AVFoundation
import MessageUI
import SVProgressHUD
import FreshchatSDK

class HomeViewController: UIViewController, XIBed {
    
    static func instantiate(dashboardApi: DashboardAPIProtocol, guestLoginApi:GuestLoginAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.dashboardApi = dashboardApi
        vc.guestLoginApi = guestLoginApi
        return vc
    }
    
    var guestLoginApi: GuestLoginAPIProtocol?
    var guestLoginDetails: GuestLoginDataResult?

    var dashboardApi: DashboardAPIProtocol?
    var dashboardResult: DashboardDataResult?
    
    weak var WishlistTabIconUpdatedDelegate: WishlistTabIconUpdated?
    weak var CartTabIconUpdatedDelegate: CartTabIconUpdated?

    @IBOutlet weak var mainScrollVw: UIScrollView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderStackVw: UIStackView!
    @IBOutlet weak var sliderStackVwWidth: NSLayoutConstraint!
    var viewArr : [UIView] = []
    var progressBarArr: [UIProgressView] = []
    var sliderTimer: Timer?
    var progressValue: Float = 0.0
    var totalSteps: Float = 100.0

    
    @IBOutlet weak var animationImgVw: UIImageView!
    @IBOutlet weak var animationThumbImgVw: UIImageView!
    @IBOutlet weak var collectionLogoImgVw: UIImageView!
    @IBOutlet weak var collectionNameLbl: UILabel!
    var collectionArr: [DashboardCollection] = []
    var currentIndex = 0
    
    @IBOutlet weak var exploreCollectionBtn: UIButton!
    
    @IBOutlet weak var categoryBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var categoryCollectionVw: UICollectionView!
    @IBOutlet weak var resourcesCollectionVw: UICollectionView!
    var resourcesArr: [DashboardResource] = []
    
    @IBOutlet weak var swipeDetectVw: UIView!
    @IBOutlet weak var resourceBaseVwHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userDefaults.isGuestLogin {
            print("Guest Login...")
            userDefaults.type = 0
            if userDefaults.accessToken.elementsEqual("") {
                self.guestLoginApiCall()
            } else {
                self.fetchDashboardApiData()
            }
        } else {
            self.freshchatCreateUser()
            self.fetchDashboardApiData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAnimation()
    }
    
    func freshchatCreateUser() {
        let userDefaults = UserDefaults.standard
        do {
            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
            
            // Create a user object
            let user = FreshchatUser.sharedInstance()
            // To set an identifiable first name for the user
            user.firstName = userDetail.fullName ?? ""
            // To set an identifiable last name for the user
            user.lastName = ""
            //To set user's email id
            user.email = userDetail.email ?? ""
            //To set user's phone number
            user.phoneCountryCode = "+1"
            user.phoneNumber = userDetail.mobileNo ?? ""
            Freshchat.sharedInstance().setUser(user)
            
            let obj = Freshchat.identifyUser(Freshchat())
            
            let restoreID = user.restoreID
            print("Your restore id is - ", restoreID)
            print("Your query external id is - ", FreshchatUser.sharedInstance().externalID)
            Freshchat.sharedInstance().identifyUser(withExternalID: "\(userDetail.userID ?? 0)", restoreID: restoreID)

        } catch {
            print(error.localizedDescription)
        }
    }

    func setupUI() {
        self.exploreCollectionBtn.layer.cornerRadius = self.exploreCollectionBtn.frame.size.height/2
        
        if Constants.Is_iPad {
            let width = (self.view.frame.width-20)/3
            self.categoryBaseVwHeight.constant = (width * 3) + 30.0
            self.resourceBaseVwHeight.constant = 300 //(resourceVWWidth * 4) + 70
        } else {
            let width = (self.view.frame.width-20)/2
            self.categoryBaseVwHeight.constant = (width * 2) + 30.0
            self.resourceBaseVwHeight.constant = 210
        }
        
        registerCell()
        
        // Add swipe gesture recognizers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        swipeDetectVw.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        swipeDetectVw.addGestureRecognizer(swipeRight)
        
        // Enable user interaction on imageView
        swipeDetectVw.isUserInteractionEnabled = true

//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        mainScrollVw.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.fetchDashboardApiData()
        }
    }
    func registerCell() {
        categoryCollectionVw.register(HomeCategoryCVC.nib(), forCellWithReuseIdentifier: HomeCategoryCVC.identifier)
        categoryCollectionVw.delegate = self
        categoryCollectionVw.dataSource = self
        
        resourcesCollectionVw.register(ResourcesDetailCVC.nib(), forCellWithReuseIdentifier: ResourcesDetailCVC.identifier)
        resourcesCollectionVw.delegate = self
        resourcesCollectionVw.dataSource = self
    }
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        sliderTimer?.invalidate()
        if self.collectionArr.count > 0 {
            
            if gesture.direction == .left {
                self.currentIndex = (currentIndex + 1) % self.collectionArr.count
                showNextImage()
            } else if gesture.direction == .right {
                currentIndex = (currentIndex - 1 + self.collectionArr.count) % self.collectionArr.count
                showPreviousImage()
            }
            
            //--> Update Progressor...
            progressValue = 0.0
            for i in 0...progressBarArr.count - 1 {
                if i < self.currentIndex {
                    self.progressBarArr[i].progress = totalSteps
                } else {
                    self.progressBarArr[i].progress = progressValue
                }
            }
            
            //--> Start the Slider for automatic animation
            sliderTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }
    }

    func showNextImage() {
        self.collectionLogoImgVw.moa.url = self.collectionArr[self.currentIndex].categoriesImage ?? ""
        self.collectionNameLbl.text = self.collectionArr[self.currentIndex].categoriesName ?? ""
        
        // Set the next image with a fade animation
        UIView.transition(with: animationImgVw, duration: 1.5, options: .transitionCrossDissolve, animations: {
            self.animationImgVw.moa.url = self.collectionArr[self.currentIndex].categoriesThumbnail ?? ""
            UIView.transition(with: self.animationThumbImgVw, duration: 1.5, options: .transitionCrossDissolve, animations: {
                self.animationThumbImgVw.moa.url = self.collectionArr[self.currentIndex].frontimage ?? ""
            }, completion: nil)
        }, completion: nil)
    }
    
    func showPreviousImage() {
        self.collectionLogoImgVw.moa.url = self.collectionArr[self.currentIndex].categoriesImage ?? ""
        self.collectionNameLbl.text = self.collectionArr[self.currentIndex].categoriesName ?? ""
        
        // Set the previous image with a fade animation
        UIView.transition(with: animationImgVw, duration: 1.5, options: .transitionCrossDissolve, animations: {
            self.animationImgVw.moa.url = self.collectionArr[self.currentIndex].categoriesThumbnail ?? ""
            UIView.transition(with: self.animationThumbImgVw, duration: 1.5, options: .transitionCrossDissolve, animations: {
                self.animationThumbImgVw.moa.url = self.collectionArr[self.currentIndex].frontimage ?? ""
            }, completion: nil)
        }, completion: nil)
    }
    
    @objc func autoAnimateNextImage() {
        showNextImage()
        print("Current Index :: \(self.currentIndex)")
        //--> Restart the timer
        sliderTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(autoAnimateNextImage), userInfo: nil, repeats: false)
    }
    
    func stopAnimation() {
        sliderTimer?.invalidate()
    }
    
    func startSliderAnimation() {
        currentIndex = 0
        sliderTimer?.invalidate()
        // Start the Slider for automatic animation
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        // Update the progress value
        progressValue += 0.1

        // Update the progress bar
        progressBarArr[self.currentIndex].progress = progressValue / totalSteps
        
        // Check if progress is complete
        if progressValue >= totalSteps {
            if self.currentIndex == self.collectionArr.count - 1 {
                self.currentIndex = 0
                //--> All Progressbar Value is 0.
                for i in 0...progressBarArr.count - 1 {
                    progressBarArr[i].progress = 0.0
                }
                print("Current \(currentIndex)")
            } else {
                self.currentIndex = self.currentIndex + 1
                print("Current Next \(currentIndex)")
            }
            showNextImage()
            // Reset progress value
            progressValue = 0.0
            // Update the progress bar
            progressBarArr[self.currentIndex].progress = 0.0
        }
    }
    
    func setupSlider(arrayCount: Int) {
        self.viewArr = []
        self.progressBarArr = []
        self.progressValue = 0.0
        self.totalSteps = 100.0

        self.sliderStackVw.removeFullyAllArrangedSubviews()
        
        var height = 0.0
        var width  = 0.0
        if Constants.Is_iPad {
            height = 30
            width = 60
        } else {
            height = 10
            width = 40
        }
        for _ in 1...arrayCount {
            let vw = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            vw.clipsToBounds = true
            
            let progressBar = UIProgressView()
            progressBar.frame = CGRect(x: 0, y: 0, width: width, height: height)
            progressBar.progressTintColor = UIColor(hex: "#FFFFFF", alpha: 1.0) // Set progress color
            progressBar.trackTintColor = UIColor(hex: "#D9D9D9", alpha: 0.6) // Set base color
            progressBarArr.append(progressBar)
            
            vw.addSubview(progressBar)
            
            sliderStackVw.addArrangedSubview(vw)
            
            let stackWidth = CGFloat(width * Double(arrayCount))
            let viewWidth = self.view.frame.size.width
            
            if stackWidth > viewWidth {
                sliderStackVwWidth.constant = viewWidth
            } else {
                sliderStackVwWidth.constant = vw.frame.size.width * CGFloat(arrayCount)
            }
            self.sliderView.layoutIfNeeded()
        }
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
                userDefaults.type = 0
                self?.fetchDashboardApiData()
            } else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
    
    @IBAction func onExploreCollectionBtnTap(_ sender: UIButton) {
        print("Explore Collection Btn...")
        let vc = ExploreCollectionVC.instantiate()
        vc.selectedCollection = self.collectionArr[self.currentIndex]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onRespurcesViewAllBtnTap(_ sender: UIButton) {
        print("Resources View All...")
        let vc = ResourcesDetailsViewController.instantiate(resourcesApi: ResourcesAPI(), faqApi: FAQAPI())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onCallBtnTap(_ sender: UIButton) {
        print("Call Contact Btn Tap...")
        let phoneNumber = Constants.contactNumber // Replace with the phone number you want to call
        if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            // Handle error or display alert
            print("Unable to open the phone dialer.")
        }
    }
    
    @IBAction func onMessageBtnTap(_ sender: UIButton) {
        print("Mail Contact Btn Tap...")
        openEmailUsingGmailApp()
    }
    
    func openEmailUsingGmailApp() {
        let recipient = Constants.supportEmail
        let subject = "Subject".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "Message body".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create a mailto URL string
        let gmailURLString = "googlegmail:///co?to=\(recipient)&subject=\(subject)&body=\(body)"
        
        if let gmailURL = URL(string: gmailURLString), UIApplication.shared.canOpenURL(gmailURL) {
            UIApplication.shared.open(gmailURL, options: [:], completionHandler: nil)
        } else {
            // Fallback to a generic mailto URL if Gmail is not available
            let mailtoURLString = "mailto:\(recipient)?subject=\(subject)&body=\(body)"
            if let mailtoURL = URL(string: mailtoURLString), UIApplication.shared.canOpenURL(mailtoURL) {
                UIApplication.shared.open(mailtoURL, options: [:], completionHandler: nil)
            } else {
                // Show an alert if no email app can handle the request
                let alertController = UIAlertController(title: "Error", message: "No email app is configured to send emails.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func fetchDashboardApiData() {
        self.stopAnimation()
        self.collectionArr = []
        self.resourcesArr = []
        self.categoryCollectionVw.reloadData()
        self.resourcesCollectionVw.reloadData()
        
        dashboardApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            self?.refreshControl.endRefreshing()
            if isSuccess {
                self?.dashboardResult = response.data
                
                self?.collectionArr = response.data?.collections ?? []
                Constants.categoryArr = self?.collectionArr ?? []   //--> Use in Wishlist page...
                self?.categoryCollectionVw.reloadData()
                if self?.collectionArr.count ?? 0 > 0 {
                    self?.setupSlider(arrayCount: self?.collectionArr.count ?? 0)
                    self?.startSliderAnimation()
                    
                    self?.animationImgVw.moa.url = self?.collectionArr[self?.currentIndex ?? 0].categoriesThumbnail ?? ""
                    self?.animationThumbImgVw.moa.url = self?.collectionArr[self?.currentIndex ?? 0].frontimage ?? ""
                    self?.collectionLogoImgVw.moa.url = self?.collectionArr[0].categoriesImage ?? ""
                    self?.collectionNameLbl.text = self?.collectionArr[0].categoriesName ?? ""
                    
                    var categoryCount = (self?.collectionArr.count ?? 0)
                    if Constants.Is_iPad {
                        let cellHeight = ((self?.categoryCollectionVw.frame.size.width ?? 0.0) - 5) / 3
                        if  categoryCount % 3 == 0 {
                            let halfCount = categoryCount / 3
                            self?.categoryBaseVwHeight.constant = cellHeight * CGFloat(halfCount)
                        } else {
                            categoryCount = categoryCount + 1
                            let halfCount = categoryCount / 3
                            self?.categoryBaseVwHeight.constant = cellHeight * CGFloat(halfCount)
                        }
                    }
                    else {
                        let cellHeight = ((self?.categoryCollectionVw.frame.size.width ?? 0.0) - 5) / 2
                        if  categoryCount % 2 == 0 {
                            let halfCount = categoryCount / 2
                            self?.categoryBaseVwHeight.constant = cellHeight * CGFloat(halfCount)
                        } else {
                            categoryCount = categoryCount + 1
                            let halfCount = categoryCount / 2
                            self?.categoryBaseVwHeight.constant = cellHeight * CGFloat(halfCount)
                        }
                    }
                }
                
                self?.resourcesArr = response.data?.resources ?? []
                self?.resourcesCollectionVw.reloadData()
                
                //Tabbar Selection as per Dashboard Response.....
                let wishlistCount = response.data?.wishlist ?? 0
                if wishlistCount == 0 {
                    userDefaults.isWishlistEmpty = true
                } else {
                    userDefaults.isWishlistEmpty = false
                }
                self?.WishlistTabIconUpdatedDelegate?.WishlistTabUpdate(type: "isComeFromWishList")

                let cartCount = response.data?.carts ?? 0
                if cartCount == 0 {
                    userDefaults.isCartEmpty = true
                } else {
                    userDefaults.isCartEmpty = false
                }
                self?.CartTabIconUpdatedDelegate?.CartTabUpdate(type: "IsComeFromCart")

            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension HomeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.categoryCollectionVw:
            return self.collectionArr.count
            
        case self.resourcesCollectionVw:
            return self.resourcesArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.categoryCollectionVw:
            let cell = categoryCollectionVw.dequeueReusableCell(withReuseIdentifier: HomeCategoryCVC.identifier, for: indexPath) as! HomeCategoryCVC
            
            let category = self.collectionArr[indexPath.row]
            cell.titleLbl.text = category.categoriesName
            cell.imgVw.moa.url = category.categoriesThumbnail
            cell.thumbImgVw.moa.url = category.frontimage
            
            return cell

        case self.resourcesCollectionVw:
            let cell = resourcesCollectionVw.dequeueReusableCell(withReuseIdentifier: ResourcesDetailCVC.identifier, for: indexPath) as! ResourcesDetailCVC
            
            let resource = self.resourcesArr[indexPath.row]
            cell.titleLbl.text = resource.name ?? ""
            cell.imgVw.moa.url = resource.image ?? ""
            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case categoryCollectionVw:
            if Constants.Is_iPad {
                let width = (self.categoryCollectionVw.frame.size.width - 5) / 3
                return CGSize(width: width, height: width)
            } else {
                let width = (self.categoryCollectionVw.frame.size.width - 5) / 2
                return CGSize(width: width, height: width)
            }
            
        case resourcesCollectionVw:
            let height = self.resourcesCollectionVw.frame.size.height - 10
            return CGSize(width: height + 35, height: height + 15)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionVw:
            if self.collectionArr.count > 0 {
                let vc = CustomizationVC.instantiate(windowDataApi: WindowDataAPI())
                vc.isEdit = false
                vc.category_id = self.collectionArr[indexPath.row].id ?? 0
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("Data empty.")
            }
            
        case resourcesCollectionVw:
            
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let videoURL = URL(string: "\(self.resourcesArr[indexPath.row].url ?? "")")
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                SVProgressHUD.dismiss()
            }

            break
            
        default:
            break
        }
    }
}

// MARK: - Dashboard API Protocol
protocol DashboardAPIProtocol {
    func getData(completion: @escaping ((DashboardDataModel?) -> Void))
}

struct DashboardAPI: DashboardAPIProtocol {
    func getData(completion: @escaping ((DashboardDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .dashboard) { (data: DashboardDataModel?) in
            completion(data)
        }
    }
}
