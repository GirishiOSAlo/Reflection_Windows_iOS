//
//  WishListViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/02/24.
//

import UIKit
import moa
import SVProgressHUD

protocol WishlistTabIconUpdated: AnyObject {
    func WishlistTabUpdate(type: String)
}


class WishListViewController: UIViewController, XIBed {
    
    static func instantiate(wishlistApi: WishListAPIProtocol, deletewishlistApi: DeleteWishListAPIProtocol, wishlistToCartApi: WishListToCartAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.wishlistApi = wishlistApi
        vc.deletewishlistApi = deletewishlistApi
        vc.wishlistToCartApi = wishlistToCartApi
        return vc
    }
    
    var wishlistApi: WishListAPIProtocol?
    var deletewishlistApi: DeleteWishListAPIProtocol?
    var wishlistToCartApi: WishListToCartAPIProtocol?

    weak var openDashboardDelegate: OpenDashboardFromBack?
    weak var CartTabIconUpdatedDelegate: CartTabIconUpdated?
    weak var WishlistTabIconUpdatedDelegate: WishlistTabIconUpdated?
    
    @IBOutlet weak var emptyWishlistVw: UIView!
    @IBOutlet weak var addedCartToastVw: UIView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var listCollectionVw: UICollectionView!
    var wishlistArr: [WishlistData] = []
    var deletedWishlistId: [Int] = []
    
    var filteredWishListArr: [WishlistData] = []
    var categoryID = 0
    
    @IBOutlet weak var categoryCollectionVw: UICollectionView!
    var categorySelectedIndex = 0
    //var categoryArr = ["All", "Calistoga Series", "Weatherford Series"]
    
    @IBOutlet weak var deleteMainPopupVw: UIView!
    @IBOutlet weak var deleteSubPopupVw: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setup() {
        self.emptyWishlistVw.isHidden = true
        self.addedCartToastVw.layer.cornerRadius = 12.0
        self.addedCartToastVw.isHidden = true
        
        self.deleteMainPopupVw.isHidden = true
        self.deleteSubPopupVw.layer.cornerRadius = 12.0
        
        registerCell()
        self.categorySelectedIndex = 0
        let indexPath = IndexPath(item: 0, section: 0)
        self.categoryCollectionVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.categoryCollectionVw.reloadData()
        if Constants.categoryArr.count > 0 {
            self.categoryID = Constants.categoryArr[self.categorySelectedIndex].id ?? 0
        } else {
            self.categoryID = -1
        }
        self.fetchWishListData()

        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        listCollectionVw.addSubview(refreshControl) // not required when using UITableViewController
    }

    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.categorySelectedIndex = 0
            let indexPath = IndexPath(item: 0, section: 0)
            self.categoryCollectionVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.categoryCollectionVw.reloadData()
            self.categoryID = Constants.categoryArr[self.categorySelectedIndex].id ?? 0
            self.fetchWishListData()
        }
    }
    
    func registerCell() {
        listCollectionVw.register(WishlistCVC.nib(), forCellWithReuseIdentifier: WishlistCVC.identifier)
        listCollectionVw.delegate = self
        listCollectionVw.dataSource = self
        
        categoryCollectionVw.register(WishListCategoryCVC.nib(), forCellWithReuseIdentifier: WishListCategoryCVC.identifier)
        categoryCollectionVw.delegate = self
        categoryCollectionVw.dataSource = self
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        userDefaults.type = 0
        self.openDashboardDelegate?.openDashboardTab()
    }
    
    //MARK: Delete Popup Button Action...
    @IBAction func onDeletePopupBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
        self.deleteWishlistApiCall(id: self.deletedWishlistId)
    }
    
    @IBAction func onMoveWishlistBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
    }

    
    func fetchWishListData() {
        self.filteredWishListArr = []
        self.wishlistArr = []
        self.listCollectionVw.reloadData()
        
        wishlistApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            self?.refreshControl.endRefreshing()
            if isSuccess {
                
                self?.wishlistArr = response.data?.wishlist ?? []

                if self?.wishlistArr.count == 0 {
                    self?.emptyWishlistVw.isHidden = false
                    userDefaults.isWishlistEmpty = true
                } else {
//                    self?.categoryID = Constants.categoryArr[self?.categorySelectedIndex ?? 0].id ?? 0
                    self?.updatedWishList()
                    self?.emptyWishlistVw.isHidden = true
                    userDefaults.isWishlistEmpty = false
                }
                //Tabbar Select Wishlist...
                self?.WishlistTabIconUpdatedDelegate?.WishlistTabUpdate(type: "isComeFromWishList")
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func addToCartDataApiCall(wishlistID: Int) {
        wishlistToCartApi?.getData(wishlist_id: wishlistID, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.showAlert(title: "Success", message: "Product added successfully in cart.")
                //Tabbar Select Cart...
                userDefaults.isCartEmpty = false
                self?.CartTabIconUpdatedDelegate?.CartTabUpdate(type: "isComeFromWishList")
                //Tabbar Select Wishlist...
                self?.WishlistTabIconUpdatedDelegate?.WishlistTabUpdate(type: "isComeFromWishList")

            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func updatedWishList() {
        if self.categorySelectedIndex == 0 {
            self.categoryID = self.categorySelectedIndex
        } else {
            let category = Constants.categoryArr[self.categorySelectedIndex-1]
            self.categoryID = category.id ?? 0
        }
        
        SVProgressHUD.show()
        self.filteredWishListArr = []
        self.listCollectionVw.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            if self.categoryID == 0 {
                self.filteredWishListArr = self.wishlistArr
            } else {
                self.filteredWishListArr = self.wishlistArr.filter { $0.categoriesID == self.categoryID }
            }
           
            self.listCollectionVw.reloadData()
            if self.filteredWishListArr.count == 0 {
                self.emptyWishlistVw.isHidden = false
            } else {
                self.emptyWishlistVw.isHidden = true
            }
            SVProgressHUD.dismiss()
        }
    }
}

extension WishListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.categoryCollectionVw:
//            return self.categoryArr.count
            return Constants.categoryArr.count + 1
            
        case self.listCollectionVw:
            return self.filteredWishListArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.categoryCollectionVw:
            let cell = categoryCollectionVw.dequeueReusableCell(withReuseIdentifier: WishListCategoryCVC.identifier, for: indexPath) as! WishListCategoryCVC
            
//            cell.categoryLbl.text = self.categoryArr[indexPath.row]
            if indexPath.row == 0 {
                cell.categoryLbl.text = "All"
            } else {
                let category = Constants.categoryArr[indexPath.row-1]
                cell.categoryLbl.text = category.categoriesName
            }
            
            if indexPath.row == self.categorySelectedIndex {
                cell.isCellSelected()
            } else {
                cell.isCellNotSelected()
            }
            return cell

        case self.listCollectionVw:
            let cell = listCollectionVw.dequeueReusableCell(withReuseIdentifier: WishlistCVC.identifier, for: indexPath) as! WishlistCVC
                        
            let product = self.filteredWishListArr[indexPath.row]
            
            cell.windowImgVw.moa.url = product.productImage ?? ""
            cell.titleLbl.text = product.productName ?? ""
            cell.starRateView.ratingValue = product.reviewCount ?? 0
            cell.priceLbl.text = "$\(product.finalprice ?? "0")"
            
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn(sender:)), for: .touchUpInside)
            
            cell.addToCartBtn.tag = indexPath.row
            cell.addToCartBtn.addTarget(self, action: #selector(tapAddToCartBtn(sender:)), for: .touchUpInside)

            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.categoryCollectionVw:
            
            if indexPath.row == 0 {
                if Constants.Is_iPad {
                    return CGSize(width: 130.0, height: 80.0)
                } else {
                    return CGSize(width: 80.0, height: 50.0)
                }
                
            } else {
                let label = UILabel(frame: CGRect.zero)
                label.text = Constants.categoryArr[indexPath.row-1].categoriesName
                label.sizeToFit()
                if Constants.Is_iPad {
                    let width = label.frame.width + 80.0
                    return CGSize(width: width, height: 80.0)
                } else {
                    let width = label.frame.width + 30.0
                    return CGSize(width: width, height: 50.0)
                }
                
            }
            
        case listCollectionVw:
            if Constants.Is_iPad {
                return CGSize(width: (self.listCollectionVw.frame.size.width/3)-10, height: 320.0)
            } else {
                return CGSize(width: (self.listCollectionVw.frame.size.width/2)-10, height: 260.0)
            }

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.categoryCollectionVw:
            self.categorySelectedIndex = indexPath.row
//            if indexPath.row == 0 {
//                self.categoryID = self.categorySelectedIndex
//            } else {
//                self.categoryID = Constants.categoryArr[self.categorySelectedIndex-1].id ?? 0
//            }
            self.updatedWishList()
            self.categoryCollectionVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.categoryCollectionVw.reloadData()
            
        case listCollectionVw:
            break

        default:
            break
        }
    }
    
    @objc func tapDeleteBtn(sender: UIButton) {
        print("Wish Product Delete Tap...")
        let wishlistID = self.filteredWishListArr[sender.tag].id ?? 0
        self.deletedWishlistId = [wishlistID]
        self.deleteMainPopupVw.isHidden = false
    }
    
    @objc func tapAddToCartBtn(sender: UIButton) {
        print("Add To Cart at \(sender.tag)")
        //self.showAddedToast()
        self.addToCartDataApiCall(wishlistID: self.filteredWishListArr[sender.tag].id ?? 0)
    }
    
    func showAddedToast() {
        self.addedCartToastVw.alpha = 1
        self.addedCartToastVw.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseInOut) {
                self.addedCartToastVw.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func deleteWishlistApiCall(id: [Int]) {
        deletewishlistApi?.getData(wishlist_id: id, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                let alert = UIAlertController(title: "Success", message: response.message ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { success in
                    self?.fetchWishListData()
                }))
                self?.present(alert, animated: true)
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
}

// MARK: - WishList API Protocol
protocol WishListAPIProtocol {
    func getData(completion: @escaping ((WishListDataModel?) -> Void))
}

struct WishListAPI: WishListAPIProtocol {
    func getData(completion: @escaping ((WishListDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .wishlist) { (data:WishListDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Delete WishList API Protocol
protocol DeleteWishListAPIProtocol {
    func getData(wishlist_id:[Int], completion: @escaping ((DeleteWishListDataModel?) -> Void))
}

struct DeleteWishListAPI: DeleteWishListAPIProtocol {
    func getData(wishlist_id: [Int], completion: @escaping ((DeleteWishListDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .deleteWishlist(wishlist_id: wishlist_id)) { (data:DeleteWishListDataModel?) in
            completion(data)
        }
    }
}

// MARK: - WishList to Cart API Protocol
protocol WishListToCartAPIProtocol {
    func getData(wishlist_id: Int, completion: @escaping ((WishListToCartDataModel?) -> Void))
}

struct WishListToCartAPI: WishListToCartAPIProtocol {
    func getData(wishlist_id: Int, completion: @escaping ((WishListToCartDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .wishlistToCart(wishlist_id: wishlist_id)) { (data: WishListToCartDataModel?) in
            completion(data)
        }
    }
}
