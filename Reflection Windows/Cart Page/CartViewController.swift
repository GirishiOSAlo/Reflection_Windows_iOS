//
//  CartViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/02/24.
//

import UIKit
import moa
import SVProgressHUD

protocol OpenDashboardFromBack: AnyObject {
    func openDashboardTab()
}

protocol CartTabIconUpdated: AnyObject {
    func CartTabUpdate(type: String)
}


class CartViewController: UIViewController, XIBed {
    
    static func instantiate(cartDataApi: CartDataAPIProtocol, deleteCartApi: DeleteCartApiProtocol, cartUpdateDataApi: CartDataUpdateAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.cartDataApi = cartDataApi
        vc.deleteCartApi = deleteCartApi
        vc.cartUpdateDataApi = cartUpdateDataApi
        return vc
    }
    
    var cartDataApi: CartDataAPIProtocol?
    var deleteCartApi: DeleteCartApiProtocol?
    var cartUpdateDataApi: CartDataUpdateAPIProtocol?
    
    var cartDataResult: CartListResult?
    var cartProductList: [Cart] = []
    private var debounceWorkItem: DispatchWorkItem?
    private var debounceWorkItemForMinus: DispatchWorkItem?

    weak var openDashboardDelegate: OpenDashboardFromBack?
    weak var CartTabIconUpdatedDelegate: CartTabIconUpdated?
    weak var WishlistTabIconUpdatedDelegate: WishlistTabIconUpdated?
    
    @IBOutlet weak var checkoutBtn: UIButton!
    @IBOutlet weak var continueShoppoingBtn: UIButton!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var clearCartBtn: UIButton!
    @IBOutlet weak var clearCartUnderlineVw: UIView!
    
    @IBOutlet weak var listCollectionVw: UICollectionView!
    
    var selectedIndex = -1
    var productIdArr: [Int] = []
    var wishlistMoveProductIndex = 0
    @IBOutlet weak var subTotalLbl: UILabel!
    
    @IBOutlet weak var deleteMainPopupVw: UIView!
    @IBOutlet weak var deleteSubPopupVw: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var wishlistBtn: UIButton!
    
    @IBOutlet weak var emptyCartVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cartProductList = []
        self.listCollectionVw.reloadData()
        fetchCartData()
    }
    
    func setupUI() {
        self.emptyCartVw.isHidden = true
        self.clearCartBtn.isHidden = true
        self.clearCartUnderlineVw.isHidden = true
        
        self.checkoutBtn.layer.cornerRadius = (checkoutBtn.frame.size.height/2)
        self.continueShoppoingBtn.layer.cornerRadius = (continueShoppoingBtn.frame.size.height/2)
        self.continueShoppoingBtn.layer.borderWidth = 1.0
        self.continueShoppoingBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        
        self.deleteMainPopupVw.isHidden = true
        self.deleteSubPopupVw.layer.cornerRadius = 12.0

        registerCell()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        listCollectionVw.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.fetchCartData()
        }
    }
    func registerCell() {
        listCollectionVw.register(CartListCVC.nib(), forCellWithReuseIdentifier: CartListCVC.identifier)
        listCollectionVw.delegate = self
        listCollectionVw.dataSource = self
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        userDefaults.type = 0
        self.openDashboardDelegate?.openDashboardTab()
    }
    
    @IBAction func onClearCartBtnTap(_ sender: UIButton) {
        print("Clear Cart Tap...")
        if self.cartProductList.count > 0 {
            self.deleteMainPopupVw.isHidden = false
            self.productIdArr = []
        }
    }
    
    @IBAction func onCHeckoutBtnTap(_ sender: UIButton) {
        print("Checkout Btn Tap...")
        if userDefaults.isGuestLogin {
            print("Login as Guest.")
//            self.navigationController?.popToRootViewController(animated: true)
            let vc = LoginVC.instantiate(loginApi: LoginAPI(), signupApi: SignUPAPI(), sendOtpApi: SendOtpAPI(), verifyOtpApi: VerifyOtpAPI(), resetPwApi: ResetPwAPI(), guestLoginApi: GuestLoginAPI())
            guard let navigationController = self.navigationController else { return }
            var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
            navigationArray.removeAll()
            navigationArray.append(vc) //To remove all previous UIViewController and append the log in view controller in navigation stack
            self.navigationController?.viewControllers = navigationArray
            self.navigationController?.popViewController(animated: true)
        }
        else {
            if self.cartProductList.count > 0 {
                //--> Check Product is not < 50 sq.ft
                var totalsqft = 0.0
                for product in cartProductList {
                    let widthString = product.width ?? ""
                    let heightString = product.height ?? ""
                    //--> Convert width and height from String to Double
                    if let widthInInches = Double(widthString), let heightInInches = Double(heightString) {
                        // Convert inches to feet
                        let widthInFeet = widthInInches / 12
                        let heightInFeet = heightInInches / 12
                        
                        //--> Calculate the area in square feet
                        let areaInSquareFeet = widthInFeet * heightInFeet
                        
                        //--> Calculation with cart count product.
                        let cartCount = product.cartCount ?? 0
                        let totalArea = areaInSquareFeet * Double(cartCount)
                        
                        //-->Round to 2 decimal places
                        let roundedArea = Double(round(100 * totalArea) / 100)
                        //print("The area is \(String(describing: roundedArea)) square feet")
                        let total = totalsqft + roundedArea
                        totalsqft = Double(round(100 * total) / 100)
                    } else {
                        self.showAlert(title: "Alert", message: "Invalid input: width and height must be numbers.")
                    }
                }
                print("Total sq.ft == \(totalsqft)")
                
                //--> Check if the rounded area is greater than 50.0
                if totalsqft >= 50.0 {
                    print("The area is \(totalsqft) square feet, which is greater than 50.0")
                    let vc = ShippingAddressVC.instantiate(addressListApi: AddressListAPI(), deleteAddressApi: DeleteAddressAPI(),addAddressApi: AddAddressAPI())
                    vc.isBillingAddress = false
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    //let msg = "The total area is \(totalsqft) sq.ft, which is not enough to proceed to cart. Please add more product."
                    self.showAlert(title: "Alert", message: "Add more items in cart, minimum order quantity is 50sq.ft")
                }
            } else {
                print("Cart List is empty.")
            }
        }
    }
    
    @IBAction func onContinueShoppingBtnTap(_ sender: UIButton) {
        print("Continue Shopping Btn Tap...")
        self.openDashboardDelegate?.openDashboardTab()
    }
    
    //MARK: Delete Popup Button Action...
    @IBAction func deletePopupCancelBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
    }
    
    @IBAction func onDeletePopupBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
        self.cartDeleteApiCall(idArr: productIdArr)
    }
    
    @IBAction func onMoveWishlistBtnTap(_ sender: UIButton) {
        print("Move to Wishlist Select...")
        self.deleteMainPopupVw.isHidden = true
        if Constants.isGuestLogin {
            self.showAlert(title: "Alert", message: "Please log in to add items to your wishlist")
        } else {
            self.movetoWishlistApiCall(CartProduct: self.cartProductList[self.wishlistMoveProductIndex])
        }
    }
    
    func fetchCartData() {
        self.selectedIndex = -1
        cartDataApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            self?.refreshControl.endRefreshing()
            if isSuccess {
                self?.cartDataResult = response.data
                
                self?.cartProductList = self?.cartDataResult?.carts ?? []
                self?.listCollectionVw.reloadData()
                
                if (self?.cartProductList.count ?? 0) > 0 {
                    let subTotal = self?.cartDataResult?.subtotal
                    self?.subTotalLbl.text = "$ \(subTotal ?? "0.0")"
                    self?.emptyCartVw.isHidden = true
                    userDefaults.isCartEmpty = false
                    self?.clearCartBtn.isHidden = false
                    self?.clearCartUnderlineVw.isHidden = false
                }
                else {
                    self?.emptyCartVw.isHidden = false
                    userDefaults.isCartEmpty = true
                    self?.clearCartBtn.isHidden = true
                    self?.clearCartUnderlineVw.isHidden = true
                }
                self?.listCollectionVw.reloadData()
                
                //Tabbar Select Cart...
                self?.CartTabIconUpdatedDelegate?.CartTabUpdate(type: "IsComeFromCart")
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
            self?.listCollectionVw.refreshControl?.endRefreshing()
        })
    }
    
    func cartDeleteApiCall(idArr: [Int]) {
        deleteCartApi?.getData(cart_id: idArr, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                SVProgressHUD.show()
                DispatchQueue.main.async {
                    self?.fetchCartData()
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    func movetoWishlistApiCall(CartProduct: Cart) {
        var dimensionArr: [DimensionData] = []
//        for detail in self.dimensionDetailsArr {
        let obj = DimensionData(cartCount: CartProduct.cartCount ?? 0, width: CartProduct.width ?? "", height: CartProduct.height ?? "")
            dimensionArr.append(obj)
//        }
        
        let leftSwing = CartProduct.leftSwing ?? 0
        let rightSwing = CartProduct.rightSwing ?? 0
        
        var glassSubOptions: [Int] = []
        let category = CartProduct.customizer?[0]
        for obj in category?.options ?? [] {
            glassSubOptions.append(obj.optionID)
        }
        
        let customizer: [Int] = [CartProduct.customizer?[0].customizerID ?? 0, CartProduct.customizer?[1].customizerID ?? 0, CartProduct.customizer?[2].customizerID ?? 0]
        let productData = CartProductData(product_id: CartProduct.productID ?? 0, left_swing: leftSwing, right_swing: rightSwing, collection_id: CartProduct.categoryID ?? 0, dimension: dimensionArr, customizer: customizer, sub_options: glassSubOptions, insectMesh: CartProduct.insectMesh)
        
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(productData) else {
            print("Failed to encode product data")
            return
        }

        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(title: "Alert", message: "Oops! No Internet Connection")
            }
        }
        else {
            SVProgressHUD.show()
            guard let url = URL(string: Constants.baseProductionURL + "addToWishlist") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let userDefault = UserDefaults.standard
            do {
                let userDetail = try userDefault.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                request.setValue("Bearer " + (userDetail.token ?? ""), forHTTPHeaderField: "Authorization")
                //            print("URL :: \(url)")
                //            print("Req :: \(request)")
            } catch {
                print(error.localizedDescription)
                //            print(error)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("Error:", error)
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                    return
                }
                
                // Check for response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    SVProgressHUD.dismiss()
                    print("Invalid response")
                    self.showAlert(title: "Error", message: "Invalid response")
                    return
                }
                
                // Parse data
                SVProgressHUD.dismiss()
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(AddToWishlistDataModel.self, from: data)
                        //print("Responce: \(res)")
                        let isSuccess: Bool = res.success!
                        DispatchQueue.main.async {
                            if isSuccess {
                                userDefaults.isWishlistEmpty = false
                                //Tabbar Select Wishlist...
                                self.WishlistTabIconUpdatedDelegate?.WishlistTabUpdate(type: "IsComeFromCart")

                                let alert = UIAlertController(title: "Success", message: "Product add to wish list successfully", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { successs in
                                }))
                                self.present(alert, animated: true)
                            }
                            else {
                                self.showAlert(title: "Alert", message: res.message ?? "")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
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
}

//MARK: Custom Methods
extension CartViewController {
    @objc func tapDropButtonBtn(sender: UIButton) {
        print("Tap Drop Btn at : \(sender.tag)")
        if sender.tag == self.selectedIndex {
            self.selectedIndex = -1
        } else {
            self.selectedIndex = sender.tag
        }
        self.listCollectionVw.reloadData()
    }
    
    func updatePlusLabel(indexPath: IndexPath) {
        if let cell = self.listCollectionVw.cellForItem(at: indexPath) as? CartListCVC {
            let currentQuantity = Int(cell.quantityLbl.text ?? "") ?? 0
            //            if currentQuantity < 10 {
            let updateQuantity = currentQuantity + 1
            cell.quantityLbl.text = "\(updateQuantity)"
            
            let product_id = self.cartProductList[indexPath.row].id ?? 0
            userDefaults.cartUpdateProductID = product_id
            // Cancel the previous work item if it exists
            debounceWorkItem?.cancel()
            
            // Create a new work item
            debounceWorkItem = DispatchWorkItem { [weak self] in
                self?.cartCountUpdateApiCall(updateQuantity: updateQuantity)
            }
            
            // Execute the new work item after a short delay (e.g., 0.5 seconds)
            if let workItem = debounceWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            }
            //                self.cartCountUpdateApiCall(updateQuantity: updateQuantity)
            //            } else {
            //                showAlert(title: "Alert!", message: "Please select maximum 10 quantity of product")
            //            }
        }
    }
    
    func updateMinusLabel(indexPath: IndexPath) {
        if let cell = self.listCollectionVw.cellForItem(at: indexPath) as? CartListCVC {
            let currentQuantity = Int(cell.quantityLbl.text ?? "") ?? 0
            if currentQuantity > 1 {
                let updateQuantity = currentQuantity - 1
                cell.quantityLbl.text = "\(updateQuantity)"
                
                let product_id = self.cartProductList[indexPath.row].id ?? 0
                userDefaults.cartUpdateProductID = product_id
                
                // Cancel the previous work item if it exists
                debounceWorkItemForMinus?.cancel()
                
                // Create a new work item
                debounceWorkItemForMinus = DispatchWorkItem { [weak self] in
                    self?.cartCountUpdateApiCall(updateQuantity: updateQuantity)
                }
                
                // Execute the new work item after a short delay (e.g., 0.5 seconds)
                if let workItem = debounceWorkItemForMinus {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
                }
//                self.cartCountUpdateApiCall(updateQuantity: updateQuantity)

            } else {
                showAlert(title: "Alert!", message: "Please select minimum 1 quantity of product")
            }
        }
    }
    
    func cartCountUpdateApiCall(updateQuantity:Int) {
        Constants.IsCartUpdate = true
        cartUpdateDataApi?.getData(cart_count: updateQuantity, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                Constants.IsCartUpdate = false
                self?.cartDataResult = response.data
                
                self?.cartProductList = self?.cartDataResult?.carts ?? []
                if (self?.cartProductList.count ?? 0) > 0 {
                    let subTotal = self?.cartDataResult?.subtotal
                    self?.subTotalLbl.text = "$ \(subTotal ?? "0.0")"
                    self?.emptyCartVw.isHidden = true
                } else {
                    self?.emptyCartVw.isHidden = false
                }
                self?.listCollectionVw.reloadData()
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    @objc func tapEditBtn(sender: UIButton) {
        print("Cart Product Edit Tap...")
        let vc = CustomizationVC.instantiate(windowDataApi: WindowDataAPI())
        vc.isEdit = true
        vc.category_id = self.cartProductList[sender.tag].categoryID ?? 0
        vc.cart_ID = "\(self.cartProductList[sender.tag].id ?? 0)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapDeleteBtn(sender: UIButton) {
        print("Cart Product Delete Tap...")
        self.deleteMainPopupVw.isHidden = false
        self.wishlistMoveProductIndex = sender.tag
        
        self.productIdArr = []
        let id = self.cartProductList[sender.tag].id ?? 0
        self.productIdArr.append(id)
        print("Product Id Arr :: \(self.productIdArr)")
    }
}

//MARK: UICollectionView Delegate Method.....
extension CartViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.listCollectionVw:
            if self.cartProductList.count > 0 {
                return self.cartProductList.count
            } else {
                return 0
            }
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.listCollectionVw:
            let cell = listCollectionVw.dequeueReusableCell(withReuseIdentifier: CartListCVC.identifier, for: indexPath) as! CartListCVC
            
            if (self.selectedIndex == -1) {
                cell.dropButton.setImage(UIImage(named: "ic_down"), for: .normal)
                cell.detailsVw.isHidden = true
            } else if indexPath.row == self.selectedIndex {
                cell.dropButton.setImage(UIImage(named: "ic_up"), for: .normal)
                cell.detailsVw.isHidden = false
            } else {
                cell.dropButton.setImage(UIImage(named: "ic_down"), for: .normal)
                cell.detailsVw.isHidden = true
            }
            
            let product = self.cartProductList[indexPath.row]
            cell.imgVw.moa.url = product.productImage
            
            let title = "\(product.categoryName ?? "") - \(product.productName ?? "")"
            cell.titleLbl.text = title
            cell.subTitleLbl.text = "\(product.width ?? "") X \(product.height ?? "") inch"
            cell.quantityLbl.text = "\(product.cartCount ?? 0)"
            cell.totalLbl.text = "Total: $\(product.finalprice ?? "")"
            
            //Swing Option...
            let swingDirection = product.isSwing ?? 0
            
            let customize = product.customizer
            if customize?.count != 0 {
                let colorCode = customize?[1].colorCode ?? "--"
                cell.colorVw.backgroundColor = UIColor(hex: colorCode, alpha: 1.0)
                cell.colorNameLbl.text = customize?[1].name ?? "--"
                
                //Add Insect Mesh...
                let isInsectMeshAdded = product.insectMesh ?? false
                if isInsectMeshAdded {
                    cell.insectMeshLbl.text = "Yes"
                } else {
                    cell.insectMeshLbl.text = "No"
                }
                
                //Swing Option View add text.....
                if swingDirection == 0 {
                    cell.swingDirectionLbl.text = "--"
                } else {
                    if product.leftSwing == 1 {
                        cell.swingDirectionLbl.text = "Left Hand Swing"
                    } else if product.rightSwing == 1 {
                        cell.swingDirectionLbl.text = "Right Hand Swing"
                    } else {
                        cell.swingDirectionLbl.text = "--"
                    }
                }
                
                cell.glassLbl.text = customize?[0].name ?? "--"
                
                //Glass Sub Option View add text.....
                let subOptions = customize?[0].options ?? []
                var subOptionStr = ""
                if subOptions.count == 0 {
                    subOptionStr = ""
                    cell.glassOptionBaseVw.isHidden = true
                }
                else {
                    cell.glassOptionBaseVw.isHidden = false
                    for (i,obj) in subOptions.enumerated() {
                        let name = obj.name
                        if i == (subOptions.count - 1) {
                            subOptionStr.append(name)
                        } else {
                            let str = "\(name), "
                            subOptionStr.append(str)
                        }
                    }
                }
                cell.glassOptionLbl.text = subOptionStr
                cell.anchorageLbl.text = customize?[2].name ?? "--"
            }
            else {
                cell.colorVw.backgroundColor = UIColor.clear
                cell.colorNameLbl.text = "--"
                cell.glassLbl.text = "--"
                cell.glassOptionLbl.text = "--"
                cell.anchorageLbl.text = "--"
            }
            
            //Swing Option Disable...
            if swingDirection == 0 {
                cell.swingBaseVw.isHidden = true
            } else {
                cell.swingBaseVw.isHidden = false
            }
            
            cell.dropButton.tag = indexPath.row
            cell.dropButton.addTarget(self, action: #selector(tapDropButtonBtn(sender:)), for: .touchUpInside)
            
            cell.plusBtnAction = { [weak self] in
                self?.updatePlusLabel(indexPath: indexPath)
            }
            cell.minusBtnAction = { [weak self] in
                self?.updateMinusLabel(indexPath: indexPath)
            }
            
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(tapEditBtn(sender:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(tapDeleteBtn(sender:)), for: .touchUpInside)

            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case listCollectionVw:
            
            let cartProduct = self.cartProductList[indexPath.row]
            
            if (self.selectedIndex == -1) { //Hide Details...
                if !Constants.Is_iPad {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 215.0)
                    
                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - 215.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - 215.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 84.0
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)
                } else {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 22.0) ?? UIFont.systemFont(ofSize: 22), width: self.view.frame.width - 255.0)

                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 19.0) ?? UIFont.systemFont(ofSize: 19), width: self.view.frame.width - 255.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 255.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 114.0
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)

                }
            }
            else if indexPath.row == self.selectedIndex { //Show Details...
                if !Constants.Is_iPad {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 215.0)
                    
                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - 215.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - 215.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 84.0
                    
                    let customize = cartProduct.customizer
                    if customize?.count != 0 {
                        //let font = UIFont(name: "Poppins-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14)
                        let font = UIFont(name: "Poppins-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14)
                        let colorName = "--"
                        let colorNameHeight = self.heightForView(text: colorName, font: font, width: self.view.frame.width - 156.0)
                        totalCellHeight = totalCellHeight + colorNameHeight
                        
                        //Add Insect Mesh...
                        let insectStatus = "Yes"
                        let insectMeshHeight = self.heightForView(text: insectStatus, font: font, width: self.view.frame.width - 178.0)
                        totalCellHeight = totalCellHeight + insectMeshHeight
                        
                        //Swing Option View Height Managed...
                        let swingDirection = cartProduct.isSwing ?? 0
                        if swingDirection == 0 {
                            print("Swing Option Hidden")
                        } else {
                            var swingDirectionStr = ""
                            if cartProduct.leftSwing == 1 {
                                swingDirectionStr = "Left Hand Swing"
                            } else if cartProduct.rightSwing == 1 {
                                swingDirectionStr = "Right Hand Swing"
                            } else {
                                swingDirectionStr = "--"
                            }
                            let swingDirectionHeight = self.heightForView(text: swingDirectionStr, font: font, width: self.view.frame.width - 200.0)
                            totalCellHeight = totalCellHeight + swingDirectionHeight
                        }
                        
                        let glassName = customize?[0].name ?? "--"
                        let glassNameHeight = self.heightForView(text: glassName, font: font, width: self.view.frame.width - 131.0)
                        totalCellHeight = totalCellHeight + glassNameHeight
                        
                        //Glass Sub Option View Height Managed...
                        let subOptions = customize?[0].options ?? []
                        var subOptionStr = ""
                        if subOptions.count == 0 {
                            subOptionStr = ""
                        }
                        else {
                            for (i,obj) in subOptions.enumerated() {
                                let name = obj.name
                                if i == (subOptions.count - 1) {
                                    subOptionStr.append(name)
                                } else {
                                    let str = "\(name), "
                                    subOptionStr.append(str)
                                }
                            }
                            let glassOptionHeight = self.heightForView(text: subOptionStr, font: font, width: self.view.frame.width - 178.0)
                            
                            if swingDirection == 0 {
                                totalCellHeight = totalCellHeight + glassOptionHeight
                            } else {
                                //extra +10.0 is managed height when swing label available...
                                totalCellHeight = totalCellHeight + glassOptionHeight + 10.0
                            }
                            //totalCellHeight = totalCellHeight + glassOptionHeight
                        }
                        
                        
                        let anchorage = customize?[2].name ?? "--"
                        let anchorageHeight = self.heightForView(text: anchorage, font: font, width: self.view.frame.width - 169.0)
                        totalCellHeight = totalCellHeight + anchorageHeight + 76.0
                    }
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)
                } else {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 22.0) ?? UIFont.systemFont(ofSize: 22), width: self.view.frame.width - 255.0)
                    
                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 19.0) ?? UIFont.systemFont(ofSize: 19), width: self.view.frame.width - 255.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 255.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 114.0
                    
                    let customize = cartProduct.customizer
                    if customize?.count != 0 {
                        let font = UIFont(name: "Poppins-SemiBold", size: 19.0) ?? UIFont.systemFont(ofSize: 19)
                        let colorName = "--"
                        let colorNameHeight = self.heightForView(text: colorName, font: font, width: self.view.frame.width - 176.0)
                        totalCellHeight = totalCellHeight + colorNameHeight
                        
                        //Add Insect Mesh...
                        let insectStatus = "Yes"
                        let insectMeshHeight = self.heightForView(text: insectStatus, font: font, width: self.view.frame.width - 198.0)
                        totalCellHeight = totalCellHeight + insectMeshHeight
                        
                        //Swing Option View Height Managed...
                        let swingDirection = cartProduct.isSwing ?? 0
                        if swingDirection == 0 {
                            print("Swing Option Hidden")
                        } else {
                            var swingDirectionStr = ""
                            if cartProduct.leftSwing == 1 {
                                swingDirectionStr = "Left Hand Swing"
                            } else if cartProduct.rightSwing == 1 {
                                swingDirectionStr = "Right Hand Swing"
                            } else {
                                swingDirectionStr = "--"
                            }
                            let swingDirectionHeight = self.heightForView(text: swingDirectionStr, font: font, width: self.view.frame.width - 200.0)
                            totalCellHeight = totalCellHeight + swingDirectionHeight
                        }
                        
                        let glassName = customize?[0].name ?? "--"
                        let glassNameHeight = self.heightForView(text: glassName, font: font, width: self.view.frame.width - 151.0)
                        totalCellHeight = totalCellHeight + glassNameHeight
                        
                        //Glass Sub Option View Height Managed...
                        let subOptions = customize?[0].options ?? []
                        var subOptionStr = ""
                        if subOptions.count == 0 {
                            subOptionStr = ""
                        }
                        else {
                            for (i,obj) in subOptions.enumerated() {
                                let name = obj.name
                                if i == (subOptions.count - 1) {
                                    subOptionStr.append(name)
                                } else {
                                    let str = "\(name), "
                                    subOptionStr.append(str)
                                }
                            }
                            let glassOptionHeight = self.heightForView(text: subOptionStr, font: font, width: self.view.frame.width - 198.0)
                            totalCellHeight = totalCellHeight + glassOptionHeight
                        }
                        
                        
                        let anchorage = customize?[2].name ?? "--"
                        let anchorageHeight = self.heightForView(text: anchorage, font: font, width: self.view.frame.width - 189.0)
                        totalCellHeight = totalCellHeight + anchorageHeight + 106.0
                    }
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)
                }
            }
            else { //Hide Details...
                if !Constants.Is_iPad {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 215.0)
                    
                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - 215.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - 215.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 84.0
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)
                } else {
                    var totalCellHeight = 0.0
                    let title = "\(cartProduct.categoryName ?? "") - \(cartProduct.productName ?? "")"
                    let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 22.0) ?? UIFont.systemFont(ofSize: 22), width: self.view.frame.width - 255.0)

                    let subTitle = "\(cartProduct.width ?? "") X \(cartProduct.height ?? "") inch"
                    let subTitleLblHeight = self.heightForView(text: subTitle, font: UIFont(name: "Poppins-SemiBold", size: 19.0) ?? UIFont.systemFont(ofSize: 19), width: self.view.frame.width - 255.0)
                    
                    let totalPrice = "Total: $\(cartProduct.finalprice ?? "")"
                    let priceLblHeight = self.heightForView(text: totalPrice, font: UIFont(name: "Poppins-Regular", size: 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - 255.0)
                    
                    totalCellHeight = titleLblHeight + subTitleLblHeight + priceLblHeight + 114.0
                    return CGSize(width: collectionView.frame.width, height: totalCellHeight)
                }
            }

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}

// MARK: - Cart Data API Protocol
protocol CartDataAPIProtocol {
    func getData(completion: @escaping ((CartListModel?) -> Void))
}

struct CartDataAPI: CartDataAPIProtocol {
    func getData(completion: @escaping ((CartListModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .cartData) { (data: CartListModel?) in
            completion(data)
        }
    }
}

// MARK: - Delete Cart  API Protocol
protocol DeleteCartApiProtocol {
    func getData(cart_id: [Int], completion: @escaping ((DeleteCartDataModel?) -> Void))
}

struct DeleteCartAPI: DeleteCartApiProtocol {
    func getData(cart_id: [Int], completion: @escaping ((DeleteCartDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .deleteCart(cart_id: cart_id)) { (data: DeleteCartDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Cart Data Update API Protocol
protocol CartDataUpdateAPIProtocol {
    func getData(cart_count:Int, completion: @escaping ((CartListModel?) -> Void))
}

struct CartDataUpdateAPI: CartDataUpdateAPIProtocol {
    func getData(cart_count: Int, completion: @escaping ((CartListModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .cartDataUpdate(cart_count: cart_count)) { (data: CartListModel?) in
            completion(data)
        }
    }
}
