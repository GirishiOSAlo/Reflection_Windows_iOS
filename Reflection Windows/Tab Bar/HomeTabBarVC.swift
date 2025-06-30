//
//  HomeTabBarVC.swift
//  JewelRich
//
//  Created by Girish Bhuva on 25/09/23.
//

import UIKit

class HomeTabBarVC: UIViewController, XIBed {
    

    lazy var homeVC: HomeViewController = {
        let vc = HomeViewController.instantiate(dashboardApi: DashboardAPI(), guestLoginApi: GuestLoginAPI())
        vc.WishlistTabIconUpdatedDelegate = self
        vc.CartTabIconUpdatedDelegate = self
        return vc
    }()

    lazy var wishListVC: WishListViewController = {
        let vc = WishListViewController.instantiate(wishlistApi: WishListAPI(), deletewishlistApi: DeleteWishListAPI(), wishlistToCartApi: WishListToCartAPI())
        vc.CartTabIconUpdatedDelegate = self
        vc.WishlistTabIconUpdatedDelegate = self
        return vc
    }()
    
    lazy var cartVC: CartViewController = {
        let vc = CartViewController.instantiate(cartDataApi: CartDataAPI(), deleteCartApi: DeleteCartAPI(), cartUpdateDataApi: CartDataUpdateAPI())
        vc.CartTabIconUpdatedDelegate = self
        vc.WishlistTabIconUpdatedDelegate = self
        return vc
    }()
    
    lazy var contactVC: ContactsViewController = {
        let vc = ContactsViewController.instantiate(zipcallusApi: ZipCallAPI())
        return vc
    }()
    
    lazy var profileVC: ProfileViewController = {
        let vc = ProfileViewController.instantiate(profileApi: ProfileAPI(), logoutApi: LogoutAPI())
        return vc
    }()
    

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var tabbarVw: UIView!
    
    @IBOutlet weak var homeView: CustomTabView!
    @IBOutlet weak var wishListView: CustomTabView!
    @IBOutlet weak var cartView: CustomTabView!
    @IBOutlet weak var contactView: CustomTabView!
    @IBOutlet weak var profileView: CustomTabView!
    
    var isComeFromCustomize: Bool = false
    var isComeFromContact: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
//        setTabViewssDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setTabViewssDelegates()
    }

    func setupUI(){

        homeView.imageName = "home_unselected"
        wishListView.imageName = "favorite_unselected"
        cartView.imageName = "shopping_unselected"
        contactView.imageName = "contact_unselected"
        profileView.imageName = "profile_unselected"
        
        if self.isComeFromCustomize {
            userDefaults.type = 2
            singleSelectTab(tab: cartView)
            showOnContainer(vc: cartVC)
            cartVC.openDashboardDelegate = self
        }
        else if self.isComeFromContact {
            userDefaults.type = 3
            singleSelectTab(tab: contactView)
            showOnContainer(vc: contactVC)
        }
//        else {
//            userDefaults.type = 0
//            singleSelectTab(tab: homeView)
//            showOnContainer(vc: homeVC)
//        }
        
        //0:home, 1:wishlist, 2:cart, 3:Contact, 4:Profile
        switch userDefaults.type {
        case 0:
            userDefaults.type = 0
            singleSelectTab(tab: homeView)
            showOnContainer(vc: homeVC)
        case 1:
            userDefaults.type = 1
            singleSelectTab(tab: wishListView)
            showOnContainer(vc: wishListVC)
        case 2:
            userDefaults.type = 2
            singleSelectTab(tab: cartView)
            showOnContainer(vc: cartVC)
        case 3:
            userDefaults.type = 3
            singleSelectTab(tab: contactView)
            showOnContainer(vc: contactVC)
        case 4:
            userDefaults.type = 4
            singleSelectTab(tab: profileView)
            showOnContainer(vc: profileVC)

        default: break
        }

        DispatchQueue.main.async {
            self.tabbarVw.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
            self.tabbarVw.layoutIfNeeded()
        }
    }
    
    func setTabViewssDelegates() {
        homeView.delegate = self
        wishListView.delegate = self
        cartView.delegate = self
        contactView.delegate = self
        profileView.delegate = self
    }
}


extension HomeTabBarVC: CustomTabSelectDelegate {
    func didSelectTab(tab: CustomTabView) {
        if tab == homeView {
            userDefaults.type = 0
            singleSelectTab(tab: tab)
            showOnContainer(vc: homeVC)
        } else if tab == wishListView {
            if userDefaults.isGuestLogin {
                Constants.isGuestLogin = userDefaults.isGuestLogin
                self.openLoginPage()
            } else {
                userDefaults.type = 1
                singleSelectTab(tab: tab)
                showOnContainer(vc: wishListVC)
                wishListVC.openDashboardDelegate = self
            }
        } else if tab == cartView {
            userDefaults.type = 2
            singleSelectTab(tab: tab)
            showOnContainer(vc: cartVC)
            cartVC.openDashboardDelegate = self
            cartVC.WishlistTabIconUpdatedDelegate = self
        } else if tab == contactView {
            userDefaults.type = 3
            singleSelectTab(tab: tab)
            showOnContainer(vc: contactVC)
        } else if tab == profileView {
            if userDefaults.isGuestLogin {
                Constants.isGuestLogin = userDefaults.isGuestLogin
                self.openLoginPage()
            } else {
                userDefaults.type = 4
                singleSelectTab(tab: tab)
                showOnContainer(vc: profileVC)
            }
        }
    }
    
    func openLoginPage() {
        let vc = LoginVC.instantiate(loginApi: LoginAPI(), signupApi: SignUPAPI(), sendOtpApi: SendOtpAPI(), verifyOtpApi: VerifyOtpAPI(), resetPwApi: ResetPwAPI(), guestLoginApi: GuestLoginAPI())
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.removeAll()
        navigationArray.append(vc) //To remove all previous UIViewController and append the sign in view controller in navigation stack
        self.navigationController?.viewControllers = navigationArray
        self.navigationController?.popViewController(animated: true)
    }
    
    func singleSelectTab(tab: CustomTabView) {
        homeView.state = tab == homeView ? .selected : .unselected
        wishListView.state = tab == wishListView ? .selected : .unselected
        if wishListView.state == .selected {
            if userDefaults.isWishlistEmpty {
                print("Selected Wishlist is Empty.")//selected without red dot...
                wishListView.imageView.image = UIImage(named: "favorite_selected")
            } else {
                print("Selected Wishlist is not Empty.")//selected with red dot...
                //wishListView.imageView.image = UIImage(named: "favorite_selectedRed")
                wishListView.imageView.image = UIImage(named: "favorite_selected")
            }
        } else {
            if userDefaults.isWishlistEmpty {
                print("Unselected Wishlist is Empty.")//unselected without red dot...
                wishListView.imageView.image = UIImage(named: "favorite_unselected")
            } else {
                print("Unselected Wishlist is not Empty.")//unselected with red dot...
                //wishListView.imageView.image = UIImage(named: "favorite_unselectedRed")
                wishListView.imageView.image = UIImage(named: "favorite_unselected")
            }
        }

        cartView.state = tab == cartView ? .selected : .unselected
        if cartView.state == .selected {
            if userDefaults.isCartEmpty {
                print("Selected Cart is Empty.")//selected without red dot...
                cartView.imageView.image = UIImage(named: "shopping_selected")
            } else {
                print("Selected Cart is not Empty.")//selected with red dot...
                cartView.imageView.image = UIImage(named: "shopping_selectedRed")
            }
        } else {
            if userDefaults.isCartEmpty {
                print("Unselected Cart is Empty.")//unselected without red dot...
                cartView.imageView.image = UIImage(named: "shopping_unselected")
            } else {
                print("Unselected Cart is not Empty.")//unselected with red dot...
                cartView.imageView.image = UIImage(named: "shopping_unselectedRed")
            }
        }
        contactView.state = tab == contactView ? .selected : .unselected
        profileView.state = tab == profileView ? .selected : .unselected
    }
    
    func showOnContainer(vc: UIViewController) {
        container.subviews.forEach({ $0.removeFromSuperview() })
        
        self.addChild(vc)
        container.addSubview(vc.view)
        vc.view.anchor(top: container.topAnchor, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor)
    }
}

//MARK: Protocol Function....
extension HomeTabBarVC: OpenDashboardFromBack {
    func openDashboardTab() {
        singleSelectTab(tab: homeView)
        showOnContainer(vc: homeVC)
    }
}

extension HomeTabBarVC: CartTabIconUpdated {
    func CartTabUpdate(type: String) {
        if type.elementsEqual("IsComeFromCart") {
            //userDefaults.type = 2
            if cartView.state == .selected {
                if userDefaults.isCartEmpty {
                    print("Selected Cart is Empty.")//selected without red dot...
                    cartView.imageView.image = UIImage(named: "shopping_selected")
                } else {
                    print("Selected Cart is not Empty.")//selected with red dot...
                    cartView.imageView.image = UIImage(named: "shopping_selectedRed")
                }
            } else {
                if userDefaults.isCartEmpty {
                    print("Unselected Cart is Empty.")//unselected without red dot...
                    cartView.imageView.image = UIImage(named: "shopping_unselected")
                } else {
                    print("Unselected Cart is not Empty.")//unselected with red dot...
                    cartView.imageView.image = UIImage(named: "shopping_unselectedRed")
                }
            }
        }
        else if type.elementsEqual("isComeFromWishList") {
            //userDefaults.type = 1
            if userDefaults.isCartEmpty {
                print("Unselected Cart is Empty.")//unselected without red dot...
                cartView.imageView.image = UIImage(named: "shopping_unselected")
            } else {
                print("Unselected Cart is not Empty.")//unselected with red dot...
                cartView.imageView.image = UIImage(named: "shopping_unselectedRed")
            }
        }
    }
}

extension HomeTabBarVC: WishlistTabIconUpdated {
    func WishlistTabUpdate(type: String) {
        if type.elementsEqual("isComeFromWishList") {
//            userDefaults.type = 1
            if wishListView.state == .selected {
                if userDefaults.isWishlistEmpty {
                    print("Selected Wishlist is Empty.")//selected without red dot...
                    wishListView.imageView.image = UIImage(named: "favorite_selected")
                } else {
                    print("Selected Wishlist is not Empty.")//selected with red dot...
                    //wishListView.imageView.image = UIImage(named: "favorite_selectedRed")
                    wishListView.imageView.image = UIImage(named: "favorite_selected")
                }
            } else {
                if userDefaults.isWishlistEmpty {
                    print("Unselected Wishlist is Empty.")//unselected without red dot...
                    wishListView.imageView.image = UIImage(named: "favorite_unselected")
                } else {
                    print("Unselected Wishlist is not Empty.")//unselected with red dot...
                    //wishListView.imageView.image = UIImage(named: "favorite_unselectedRed")
                    wishListView.imageView.image = UIImage(named: "favorite_unselected")
                }
            }
        }
        else if type.elementsEqual("IsComeFromCart") {
//            userDefaults.type = 2
            if userDefaults.isWishlistEmpty {
                print("Unselected Wishlist is Empty.")//unselected without red dot...
                wishListView.imageView.image = UIImage(named: "favorite_unselected")
            } else {
                print("Unselected Wishlist is not Empty.")//unselected with red dot...
                //wishListView.imageView.image = UIImage(named: "favorite_unselectedRed")
                wishListView.imageView.image = UIImage(named: "favorite_unselected")
            }
        }
    }
}
