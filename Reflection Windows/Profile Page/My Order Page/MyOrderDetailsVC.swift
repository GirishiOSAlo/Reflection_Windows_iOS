//
//  MyOrderDetailsVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 20/03/24.
//

import UIKit
import moa
import SVProgressHUD

class MyOrderDetailsVC: UIViewController, XIBed, RatingViewDelegate {
    
    static func instantiate(preOrderDetailsApi: PreOrderDetailsAPIProtocol, productRatingApi: ProductRatingAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.preOrderDetailsApi = preOrderDetailsApi
        vc.productRatingApi = productRatingApi
        return vc
    }
    
    var preOrderDetailsApi: PreOrderDetailsAPIProtocol?
    var productRatingApi: ProductRatingAPIProtocol?

    var productArr: [PreOrderDetailProduct] = []
    var trackOrderList: [PreOrderDetailTracking] = []

    var preOrder: PreOrderData?
    @IBOutlet weak var mainScrollVw: UIScrollView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var estimatedBaseVw: UIView!
    @IBOutlet weak var deliveryTitleLbl: UILabel!
    @IBOutlet weak var estimatedDeliveryDateLbl: UILabel!
    
    @IBOutlet weak var productListBaseVw: UIView!
    @IBOutlet weak var productListVwHeight: NSLayoutConstraint!
    @IBOutlet weak var productListCollectionVw: UICollectionView!
    
    @IBOutlet weak var orderDetailBaseVw: UIView!
    @IBOutlet weak var orderDateLbl: UILabel!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var orderTotalLbl: UILabel!

    @IBOutlet weak var shippingDetailsBaseVw: UIView!
    @IBOutlet weak var shippingTitleLbl: UILabel!
    @IBOutlet weak var shippingAddressLbl: UILabel!
    @IBOutlet weak var shippingMobileNoLbl: UILabel!
    
    @IBOutlet weak var trackOrderBaseVw: UIView!
    
    @IBOutlet weak var backToHomeBtn: UIButton!

    @IBOutlet weak var trackOrderCollectionVw: UICollectionView!
    @IBOutlet weak var trackOrderCollectionHeight: NSLayoutConstraint!
    var trackOrderImgArr = ["ic_OrderPlaced","ic_shipped","ic_outOfDelivery","ic_OrderDelivered"]
    
    var submittedUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchPreOrderDetaisData(id: self.preOrder?.id ?? 0)
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        userDefaults.type = 4
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        self.estimatedBaseVw.layer.cornerRadius = 12.0
        self.productListBaseVw.layer.cornerRadius = 12.0
        self.orderDetailBaseVw.layer.cornerRadius = 12.0
        self.shippingDetailsBaseVw.layer.cornerRadius = 12.0
        self.trackOrderBaseVw.layer.cornerRadius = 12.0
        
        self.backToHomeBtn.layer.cornerRadius = self.backToHomeBtn.frame.size.height/2
        self.backToHomeBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.backToHomeBtn.layer.borderWidth = 1.0

        productListCollectionVw.register(MyOrderProductsCVC.nib(), forCellWithReuseIdentifier: MyOrderProductsCVC.identifier)
        productListCollectionVw.delegate = self
        productListCollectionVw.dataSource = self
        
        trackOrderCollectionVw.register(TrackOrderCVC.nib(), forCellWithReuseIdentifier: TrackOrderCVC.identifier)
        trackOrderCollectionVw.delegate = self
        trackOrderCollectionVw.dataSource = self


        //==> 1 value is count of product list count...
        //self.productListVwHeight.constant = (80.0 * 1) + 50.0
        self.productListVwHeight.constant = 0.0
        self.trackOrderCollectionHeight.constant = 0.0
        
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        mainScrollVw.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.fetchPreOrderDetaisData(id: self.preOrder?.id ?? 0)
        }
    }

    @IBAction func onSeeProductDataBtnTap(_ sender: UIButton) {
        print("See Product Data...")
        let url = URL(string: self.submittedUrl)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction func onDownloadInvoiceBtnTap(_ sender: UIButton) {
        print("Download Invoice...")
        let userDefaults = UserDefaults.standard
        do {
            let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
            
            guard let url = URL(string: Constants.baseProductionURL + "orderInvoice?id=\(self.preOrder?.id ?? 0)&uid=\(userDetail.userID ?? 0)") else {
                print("Invalid URL")
                return
            }
            //==> Open URL in browser...
            UIApplication.shared.open(url)

        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onNeedHelpBtnTap(_ sender: UIButton) {
        userDefaults.type = 3
        let vc = HomeTabBarVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBackToHomeBtnTap(_ sender: UIButton) {
        userDefaults.type = 0
        let vc = HomeTabBarVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchPreOrderDetaisData(id:Int) {
        preOrderDetailsApi?.getData(id: id, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            self?.refreshControl.endRefreshing()
            if isSuccess {
                DispatchQueue.main.async {
                    self?.setupData(detail: response.data?.order)
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    func setupData(detail: PreOrderDetailOrder?) {
        self.submittedUrl = detail?.submittalsURL ?? ""
        self.estimatedDeliveryDateLbl.text = detail?.estimatedDelivery ?? ""
        
        self.productArr = detail?.products ?? []
        self.productListCollectionVw.reloadData()
        
        self.orderDateLbl.text = "Order date : \(detail?.orderDate ?? "--")"
        self.orderNoLbl.text = "Order No : \(detail?.orderNo ?? "--")"
        self.orderTotalLbl.text = "Order Total : \(detail?.orderTotal ?? "--")"
        
        let shippingDetail = detail?.shippingAddress
        self.shippingTitleLbl.text = "Shipping to \(shippingDetail?.name ?? "")"
        self.shippingMobileNoLbl.text = shippingDetail?.mobileNumber ?? ""
        let addressLine1 = shippingDetail?.addressLine1 ?? ""
        let addressLine2 = shippingDetail?.addressLine2 ?? ""
        let city = shippingDetail?.city ?? ""
        let state = shippingDetail?.state ?? ""
        let pincode = shippingDetail?.pincode ?? ""
        self.shippingAddressLbl.text = "\(addressLine1), \(addressLine2), \(city), \(state) - \(pincode)"

        self.trackOrderList = detail?.tracking ?? []
        self.trackOrderCollectionHeight.constant = CGFloat(80 * trackOrderList.count)
        self.trackOrderCollectionVw.reloadData()
        
//        let productListCount = detail?.products?.count ?? 0
//        if productListCount > 0 {
//            if self.trackOrderList[3].status == false {
//                self.deliveryTitleLbl.text = "Estimated delivery :"
//                self.productListVwHeight.constant = CGFloat((80 * productListCount) + 70)
//            } else {
//                self.deliveryTitleLbl.text = "Delivered :"
//                self.productListVwHeight.constant = CGFloat((130 * productListCount) + 70)
//            }
//        } else {
//            self.productListVwHeight.constant = 0.0
//        }
        
        var productListVwHeight = 0.0
        if self.productArr.count > 0 {
            for product in self.productArr {
                let title = "\(product.category ?? "") - \(product.productName ?? "")"
                let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16), width: self.view.frame.width - 132.0)
                
                let totalPrice = "$\(product.totalPrice ?? "")"
                let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
                let color = product.color ?? ""
                let glass = product.glass ?? ""
                let anchorage = product.anchorage ?? ""
                let quantity = product.cartCount ?? 0
                let subDetail = "\(totalPrice),\n\(dimension), \(color), \(glass), \(anchorage), Qty = \(quantity)"
                let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - 132.0)
                
                let finalLblHeight = productNameHeight + subDetailHeight + 21.0 //25 = top bottom margin...
                
                if finalLblHeight < 78.0 {
                    productListVwHeight = productListVwHeight + 78.0
                } else {
                    productListVwHeight = productListVwHeight + finalLblHeight
                }
                
            }
        }
        
        if self.trackOrderList[3].status == false {
            self.deliveryTitleLbl.text = "Estimated delivery :"
            self.productListVwHeight.constant = productListVwHeight + 60
        } else {
            self.deliveryTitleLbl.text = "Delivered :"
            let rateHeight = Double((50 * self.productArr.count) + 60)
            self.productListVwHeight.constant = productListVwHeight + rateHeight
        }
    }
    
    //MARK: Rate View Delegate Method...
    func updateRatingFormatValue(_ value: Int, tag: Int) {
        print("Rating : \(value)")
        let obj = self.preOrder?.products?[tag]
        
        //==> Call Rate API...
        productRatingApi?.getData(order_id: preOrder?.id ?? 0, order_detail_id: obj?.orderDetailID ?? 0, product_id: obj?.productID ?? 0, rating: value, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                self?.showAlert(title: "Success", message: response.message ?? "Error")
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
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


extension MyOrderDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.productListCollectionVw:
            return self.productArr.count 
            
        case self.trackOrderCollectionVw:
            return self.trackOrderList.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.productListCollectionVw:
            let cell = productListCollectionVw.dequeueReusableCell(withReuseIdentifier: MyOrderProductsCVC.identifier, for: indexPath) as! MyOrderProductsCVC
            
            let product = self.productArr[indexPath.row]
            cell.productImgVw.moa.url = product.productImage ?? ""
            let title = "\(product.category ?? "") - \(product.productName ?? "")"
            cell.productTitleLbl.text = title
            
            let totalPrice = "$\(product.totalPrice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            let color = product.color ?? ""
            let glass = product.glass ?? ""
            let anchorage = product.anchorage ?? ""
            let quantity = product.cartCount ?? 0
            cell.productSubTitleLbl.text = "\(totalPrice),\n\(dimension), \(color), \(glass), \(anchorage), Qty = \(quantity)"
            
            cell.rateView.delegate = self
            cell.rateView.tag = indexPath.row
            
            if self.trackOrderList[3].status == false {  //Process...
                cell.rateVwHeight.constant = 0.0
                cell.underlineVw.isHidden = true
            }
            else {  //Delivered...
                cell.rateVwHeight.constant = 50.0
                
                var rating = product.ratings ?? 0
                cell.rateView.ratingValue = rating
                
                if rating == 0 {
                    cell.rateView.isUserInteractionEnabled = true
                } else {
                    cell.rateView.isUserInteractionEnabled = false //already given rate...
                }
            }
            
            if indexPath.row == self.productArr.count - 1 {
                cell.underlineVw.isHidden = true
            } else {
                cell.underlineVw.isHidden = false
            }
            
            return cell
            
        case self.trackOrderCollectionVw:
            let cell = trackOrderCollectionVw.dequeueReusableCell(withReuseIdentifier: TrackOrderCVC.identifier, for: indexPath) as! TrackOrderCVC

            cell.imgVw.image = UIImage(named: self.trackOrderImgArr[indexPath.row])
            let track = self.trackOrderList[indexPath.row]
            cell.titleLbl.text = track.title ?? ""
            cell.subTitleLbl.text = track.date ?? ""
            
            if (indexPath.row == 0) {
                cell.topProgressLineVw.isHidden = true
            } else {
                cell.topProgressLineVw.isHidden = false
            }

            //==> Order Track Progressing.....
            if track.status == true {  //Selected...
                cell.imageBaseVw.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
                cell.topProgressLineVw.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
            } else {  //Unselected...
                cell.imageBaseVw.backgroundColor = UIColor(hex: "#D1D1D1", alpha: 1.0)
                cell.topProgressLineVw.backgroundColor = UIColor(hex: "#D1D1D1", alpha: 1.0)
            }
            
            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case productListCollectionVw:
//            if self.trackOrderList[3].status == false {  //Rating Hidden...
//                return CGSize(width: self.productListCollectionVw.frame.size.width, height: 80.0)
//            }
//            else {  //Rating Show...
//                return CGSize(width: self.productListCollectionVw.frame.size.width, height: 130.0)
//            }
            var productListVwHeight = 0.0
            let product = self.productArr[indexPath.row]
            
            let title = "\(product.category ?? "") - \(product.productName ?? "")"
            let productNameHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16), width: self.view.frame.width - 132.0)
            
            let totalPrice = "$\(product.totalPrice ?? "")"
            let dimension = "\(product.width ?? "") X \(product.height ?? "") inch"
            let color = product.color ?? ""
            let glass = product.glass ?? ""
            let anchorage = product.anchorage ?? ""
            let quantity = product.cartCount ?? 0
            let subDetail = "\(totalPrice),\n\(dimension), \(color), \(glass), \(anchorage), Qty = \(quantity)"
            let subDetailHeight = self.heightForView(text: subDetail, font: UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - 132.0)
            
            let finalLblHeight = productNameHeight + subDetailHeight + 21.0 //21 = top bottom margin...
            
            if finalLblHeight < 78.0 {
                productListVwHeight = 78.0
            } else {
                productListVwHeight = finalLblHeight
            }
            
            if self.trackOrderList[3].status == false {
                return CGSize(width: self.productListCollectionVw.frame.size.width, height: productListVwHeight)
            } else {
                return CGSize(width: self.productListCollectionVw.frame.size.width, height: productListVwHeight + 60)
            }
            
        case trackOrderCollectionVw:
            return CGSize(width: self.trackOrderCollectionVw.frame.size.width, height: 80.0)

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case productListCollectionVw:
            print(indexPath.row)
            
        case trackOrderCollectionVw: break

        default: break
        }
    }
}

// MARK: - Pre Order Details API Protocol
protocol PreOrderDetailsAPIProtocol {
    func getData(id: Int, completion: @escaping ((PreOrderDetailDataModel?) -> Void))
}

struct PreOrderDetailsAPI: PreOrderDetailsAPIProtocol {
    func getData(id: Int, completion: @escaping ((PreOrderDetailDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .prevOrderDetails(id: id)) { (data:PreOrderDetailDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Product Rating API Protocol
protocol ProductRatingAPIProtocol {
    func getData(order_id: Int, order_detail_id: Int, product_id: Int, rating: Int, completion: @escaping ((ProductRateModel?) -> Void))
}

struct ProductRatingAPI: ProductRatingAPIProtocol {
    func getData(order_id: Int, order_detail_id: Int, product_id: Int, rating: Int, completion: @escaping ((ProductRateModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .productRating(order_id: order_id, order_detail_id: order_detail_id, product_id: product_id, rating: rating)) { (data:ProductRateModel?) in
            completion(data)
        }
    }
}
