//
//  MyOrderVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 26/02/24.
//

import UIKit
import moa

class MyOrderVC: UIViewController, XIBed, UITextFieldDelegate {
    
    static func instantiate(preOrderApi: PreOrderAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.preOrderApi = preOrderApi
        return vc
    }
    
    var preOrderApi: PreOrderAPIProtocol?

    @IBOutlet weak var searchMainVw: UIView!
    @IBOutlet weak var searchBaseVw: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var filterBtnBaseVw: UIView!
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var orderListTblVw: UITableView!
    var orderList: [PreOrderData] = []
    
    var titleArr = ["Shipped","Delivered","Cancelled"]
    var subArr = ["On Monday, 21 Dec-2023 as per your request","On Monday, 11 Jan-2023","On Monday, 21 Dec-2023 as per your request"]
    var imgArr = ["ic_Shipping","ic_Delivered","ic_Cancelled"]
    
    
    @IBOutlet weak var filterMainPopupVw: UIView!
    @IBOutlet weak var filterSubVw: UIView!
    @IBOutlet weak var clearFilterBtn: UIButton!
    @IBOutlet weak var applyFilterBtn: UIButton!
    
    @IBOutlet weak var orderStatusFilterVw: UIView!
    @IBOutlet weak var orderStatusCollectionVw: UICollectionView!
    var orderStatusArr = ["All","Pending Orders","Past Orders"]
    var orderStatusSelectedIndex = 0
    
    @IBOutlet weak var orderTimeFilterVw: UIView!
    @IBOutlet weak var orderTimeCollectionVw: UICollectionView!
    var orderTimeArr = ["Anytime","Last 30 days","Last 6 months","Last year"]
    var orderTimeSelectedIndex = 0
    
    @IBOutlet weak var noOrderView: UIView!
    
    var status: String!
    var time: Int!
    var limit: Int!
    var currentPage: Int!
    var lastPage: Int!
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.status = "all"
        self.time = 0
        self.limit = 10
        self.currentPage = 1
        self.orderList.removeAll()
        self.orderListTblVw.reloadData()

        fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
    }

    func setupUI() {
        self.searchMainVw.isHidden = true
        self.noOrderView.isHidden = true
        self.searchBaseVw.layer.cornerRadius = self.searchBaseVw.frame.size.height/2
        self.searchBaseVw.layer.borderWidth = 1.0
        self.searchBaseVw.layer.borderColor = UIColor(hex: "#CCCCCC", alpha: 1.0).cgColor
        
        self.filterBtnBaseVw.layer.cornerRadius = self.filterBtnBaseVw.frame.size.height/2
        self.filterBtnBaseVw.layer.borderWidth = 1.0
        self.filterBtnBaseVw.layer.borderColor = UIColor(hex: "#CCCCCC", alpha: 1.0).cgColor
        
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(self.searchTextFieldDidChange(_:)), for: .editingChanged)

        self.registerCell()
        self.setupFilterPopup()
        
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        orderListTblVw.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.orderList.removeAll()
        self.orderListTblVw.reloadData()
        DispatchQueue.main.async {
            self.limit = 10
            self.currentPage = 1
            self.fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
        }
    }
   
    func registerCell() {
        orderListTblVw.register(MyOrderTVC.nib(), forCellReuseIdentifier: MyOrderTVC.indentifier)
        orderListTblVw.delegate = self
        orderListTblVw.dataSource = self

        orderStatusCollectionVw.register(FIlterOrderCVC.nib(), forCellWithReuseIdentifier: FIlterOrderCVC.identifier)
        orderStatusCollectionVw.delegate = self
        orderStatusCollectionVw.dataSource = self
        
        orderTimeCollectionVw.register(FIlterOrderCVC.nib(), forCellWithReuseIdentifier: FIlterOrderCVC.identifier)
        orderTimeCollectionVw.delegate = self
        orderTimeCollectionVw.dataSource = self
    }
    
    func setupFilterPopup() {
        self.filterMainPopupVw.isHidden = true
        
        self.applyFilterBtn.layer.cornerRadius = self.applyFilterBtn.frame.size.height/2
        self.clearFilterBtn.layer.cornerRadius = self.clearFilterBtn.frame.size.height/2
        self.clearFilterBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 0.5).cgColor
        self.clearFilterBtn.layer.borderWidth = 1.0
        self.orderStatusFilterVw.layer.cornerRadius = 12.0
        self.orderTimeFilterVw.layer.cornerRadius = 12.0
        DispatchQueue.main.async {
            self.filterSubVw.roundCorners(corners: [.topLeft, .topRight], radius: 12.0)
            self.filterSubVw.layoutIfNeeded()
        }
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        print("Search Text :: \(self.searchTextField.text ?? "")")
        self.orderList.removeAll()
        self.orderListTblVw.reloadData()
        DispatchQueue.main.async {
            self.limit = 10
            self.currentPage = 1
            self.fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
        }
    }
    
    @IBAction func onFIlterBtnTap(_ sender: UIButton) {
        self.filterMainPopupVw.isHidden = false
    }
    
    //MARK: Popup Button Action.....
    @IBAction func onFilterPopupCLoseBtnTap(_ sender: UIButton) {
        self.filterMainPopupVw.isHidden = true
    }
    
    @IBAction func onClearFilterBtnTap(_ sender: UIButton) {
        self.filterMainPopupVw.isHidden = true
        self.orderStatusSelectedIndex = 0
        self.orderStatusCollectionVw.reloadData()
        self.orderTimeSelectedIndex = 0
        self.orderTimeCollectionVw.reloadData()
        
        self.status = "all"
        self.time = 0
        self.limit = 10
        self.currentPage = 1
        self.orderList.removeAll()
        self.orderListTblVw.reloadData()
        fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
    }
    
    @IBAction func onApplyFilterBtnTap(_ sender: UIButton) {
        self.filterMainPopupVw.isHidden = true
        self.limit = 10
        self.currentPage = 1
        self.orderList.removeAll()
        self.orderListTblVw.reloadData()
        fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
    }
    
    func fetchPreOrderData(page:Int, status:String, time:Int, search: String, limit:Int) {
        preOrderApi?.getData(page: page, status: status, time: time, search: search, limit: limit, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            self?.refreshControl.endRefreshing()
            if response.statusCode == 200 {
                if isSuccess {
                    self?.lastPage = response.data?.lastPage ?? 0
                    let list = response.data?.data ?? []
                    self?.orderList.append(contentsOf: list)
                    self?.orderListTblVw.reloadData()
                    if (self?.orderList.count ?? 0) > 0 {
                        self?.searchMainVw.isHidden = false
                        self?.noOrderView.isHidden = true
                    } else {
                        self?.searchMainVw.isHidden = true
                        self?.noOrderView.isHidden = false
                    }
                } else {
                    self?.searchMainVw.isHidden = false
                    self?.noOrderView.isHidden = false
                }
            }
            else {
                self?.showAlert(title: "Alert", message: "Something went wrong.")
            }
        })
    }
}

extension MyOrderVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.orderStatusCollectionVw:
            return self.orderStatusArr.count
            
        case self.orderTimeCollectionVw:
            return self .orderTimeArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.orderStatusCollectionVw:
            let cell = orderStatusCollectionVw.dequeueReusableCell(withReuseIdentifier: FIlterOrderCVC.identifier, for: indexPath) as! FIlterOrderCVC
            cell.lbl.text = self.orderStatusArr[indexPath.row]
            if orderStatusSelectedIndex == indexPath.row {
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
            } else {
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
            }
            return cell
            
        case self.orderTimeCollectionVw:
            let cell = orderTimeCollectionVw.dequeueReusableCell(withReuseIdentifier: FIlterOrderCVC.identifier, for: indexPath) as! FIlterOrderCVC
            cell.lbl.text = self.orderTimeArr[indexPath.row]
            if orderTimeSelectedIndex == indexPath.row {
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
            } else {
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
            }
            return cell

        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = 0.0
        switch collectionView {
        case self.orderStatusCollectionVw:
            
            Constants.Is_iPad ? (height = 40.0) : (height = 30.0)
            return CGSize(width: self.orderStatusCollectionVw.frame.size.width, height: height)
            
        case self.orderTimeCollectionVw:
            Constants.Is_iPad ? (height = 40.0) : (height = 30.0)
            return CGSize(width: self.orderTimeCollectionVw.frame.size.width, height: height)

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.orderStatusCollectionVw:
            self.orderStatusSelectedIndex = indexPath.row
            self.orderStatusCollectionVw.reloadData()
            
            if (indexPath.row == 0) {
                self.status = "all"
            } else if (indexPath.row == 1) {
                self.status = "pending"
            } else if (indexPath.row == 2) {
                self.status = "past"
            }

        case self.orderTimeCollectionVw:
            self.orderTimeSelectedIndex = indexPath.row
            self.orderTimeCollectionVw.reloadData()

            if (indexPath.row == 0) {
                self.time = 0 //all...
            } else if (indexPath.row == 1) {
                self.time = 1 //last 30 days...
            } else if (indexPath.row == 2) {
                self.time = 1 //last 6 months...
            } else if (indexPath.row == 3) {
                self.time = 2 //last year...
            }

        default: break
        }
    }
}

//MARK: UITableview Delegate Method.....
extension MyOrderVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orderListTblVw.dequeueReusableCell(withIdentifier: MyOrderTVC.indentifier, for: indexPath) as! MyOrderTVC
                
        let preOrder = self.orderList[indexPath.row]
        cell.orderNoLbl.text = "Order No. \(preOrder.orderNo ?? "")"
        cell.statusSubLbl.text = preOrder.orderDate ?? ""
        cell.itemsLbl.text = "\(preOrder.products?.count ?? 0) items"
        
        let firstProduct = preOrder.products?[0]
        cell.imgVw.moa.url = firstProduct?.productImage ?? ""
        let title = "\(firstProduct?.category ?? "") - \(firstProduct?.productName ?? "")"
        cell.titleLbl.text = title
        cell.subTitleLbl.text = "$\(firstProduct?.totalPrice ?? "")"
        
        let status = preOrder.status ?? ""
        //In Transist
        //processing
        //Completed
        
        if status.elementsEqual("processing") {
            cell.statusImgVw.image = UIImage(named: "ic_Processing")
            cell.statusTitleLbl.text = "Processing"
            cell.statusTitleLbl.textColor = UIColor(hex: "#151515", alpha: 1.0)
        }
        else if status.elementsEqual("In Transist") {
            cell.statusImgVw.image = UIImage(named: "ic_Shipping")
            cell.statusTitleLbl.text = "Shipped"
            cell.statusTitleLbl.textColor = UIColor(hex: "#151515", alpha: 1.0)
        }
        else if status.elementsEqual("Completed") {
            cell.statusImgVw.image = UIImage(named: "ic_Delivered")
            cell.statusTitleLbl.text = "Delivered"
            cell.statusTitleLbl.textColor = UIColor(hex: "#0A9B33", alpha: 1.0)
        }
        else {
            cell.statusImgVw.image = UIImage(named: "ic_Cancelled")
            cell.statusTitleLbl.text = status
            cell.statusTitleLbl.textColor = UIColor(hex: "#151515", alpha: 1.0)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Is_iPad ?  335.0 : 185.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MyOrderDetailsVC.instantiate(preOrderDetailsApi: PreOrderDetailsAPI(), productRatingApi: ProductRatingAPI())
        vc.preOrder = self.orderList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Pagination Logic
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5, !isLoading {
            loadMoreData()
        }
    }
    
    func loadMoreData() {
        guard !isLoading else { return }
        
        if self.lastPage == self.currentPage {
            isLoading = false
            print("Current page is Last Page")
        } else {
            isLoading = true
            currentPage += 1
            print("Current page : \(self.currentPage ?? 0)")
            self.fetchPreOrderData(page: self.currentPage, status: self.status, time: self.time, search: self.searchTextField.text ?? "", limit: self.limit)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { // Simulating network delay
            let newItems = (1...self.limit).map { "Item \((self.currentPage - 1) * self.limit + $0)" }
            //self.data.append(contentsOf: newItems)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.orderListTblVw.reloadData()
            }
        }
    }
}


// MARK: - Pre Order  API Protocol
protocol PreOrderAPIProtocol {
    func getData(page: Int, status: String, time: Int, search: String, limit: Int, completion: @escaping ((PreOrderDataModel?) -> Void))
}

struct PreOrderAPI: PreOrderAPIProtocol {
    func getData(page: Int, status: String, time: Int, search: String, limit: Int, completion: @escaping ((PreOrderDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .prevOrder(page: page, status: status, time: time, search: search, limit: limit)) { (data:PreOrderDataModel?) in
            completion(data)
        }
    }
}
