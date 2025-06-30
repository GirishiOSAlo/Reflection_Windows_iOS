//
//  HelpCenterVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 27/02/24.
//

import UIKit
import moa

protocol OpenAllOrderDelegate: AnyObject {
    func openAllOrderFromHelp()
}

class HelpCenterVC: UIViewController, XIBed {
    
    static func instantiate(preOrderApi: PreOrderAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.preOrderApi = preOrderApi
        return vc
    }
    var preOrderApi: PreOrderAPIProtocol?
    var orderList: [PreOrderData] = []
    var productList: [PreOrderProduct] = []
    
    
    @IBOutlet weak var mainScrollVw: UIScrollView!
    @IBOutlet weak var bgView: UIView!
    weak var delegate: OpenAllOrderDelegate?

    @IBOutlet weak var orderStatusLbl: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var orderListCollectionVw: UICollectionView!
    @IBOutlet weak var orderCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPreOrderData(page: 1, status: "all", time: 2, search: "", limit: 1)
    }

    func setupUI() {
        self.bgView.layer.cornerRadius = 12.0
        self.mainScrollVw.isHidden = true
        self.emptyView.isHidden = true
        self.orderCollectionHeight.constant = 0.0

        orderListCollectionVw.register(HelpCenterCVC.nib(), forCellWithReuseIdentifier: HelpCenterCVC.identifier)
        orderListCollectionVw.delegate = self
        orderListCollectionVw.dataSource = self
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onViewAllBtnTap(_ sender: UIButton) {
        print("View All Orders")
        delegate?.openAllOrderFromHelp()
    }
    
    func fetchPreOrderData(page:Int, status:String, time:Int, search: String, limit:Int) {
        self.orderList.removeAll()
        self.productList.removeAll()
        self.orderListCollectionVw.reloadData()
        preOrderApi?.getData(page: page, status: status, time: time, search: search, limit: limit, completion: { [weak self] (data) in
            guard let response = data else { return }
//            let isSuccess: Bool = response.success!

//            if isSuccess {
            if response.statusCode == 200 {
                let list = response.data?.data ?? []
                self?.orderList.append(contentsOf: list)
                
                if self?.orderList.count ?? 0 > 0 {
                    self?.mainScrollVw.isHidden = false
                    self?.emptyView.isHidden = true
                    self?.productList = self?.orderList[0].products ?? []
                    self?.orderListCollectionVw.reloadData()
                    self?.orderStatusLbl.text = self?.orderList[0].status ?? ""
                    self?.subLabel.text = self?.orderList[0].orderDate ?? ""
                } else {
                    self?.mainScrollVw.isHidden = true
                    self?.emptyView.isHidden = false
                }
                let margin = Constants.Is_iPad ? 220 : 155
                self?.orderCollectionHeight.constant = CGFloat((self?.productList.count ?? 0) * margin)
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
}


extension HelpCenterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.orderListCollectionVw:
//            return self.orderList.count
            return self.productList.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.orderListCollectionVw:
            let cell = orderListCollectionVw.dequeueReusableCell(withReuseIdentifier: HelpCenterCVC.identifier, for: indexPath) as! HelpCenterCVC
            
            let product = self.productList[indexPath.row]
            cell.imgVw.moa.url = product.productImage ?? ""
            cell.titleLbl.text = product.productName ?? ""
            cell.subTitleLbl.text = "$\(product.totalPrice ?? "")"
            
            cell.rateView.ratingValue = product.rating ?? 0
            cell.rateView.isUserInteractionEnabled = false
//            if self.trackOrderList[3].status == false {  //Process...
//                cell.rateVwHeight.constant = 0.0
//                cell.underlineVw.isHidden = true
//            }
//            else {  //Delivered...
            cell.rateVwHeight.constant = CGFloat(Constants.Is_iPad ? 70.0 : 50.0)
                
                if indexPath.row == self.productList.count - 1 {
                    cell.underlineVw.isHidden = true
                } else {
                    cell.underlineVw.isHidden = false
                }
//            }

            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case orderListCollectionVw:
//            if self.trackOrderList[3].status == false {  //Rating Hidden...
//                return CGSize(width: self.productListCollectionVw.frame.size.width, height: 80.0)
//            }
//            else {  //Rating Show...
            return CGSize(width: self.orderListCollectionVw.frame.size.width, height: Constants.Is_iPad ? 220.0 : 155.0)
//            }

//            return CGSize(width: self.orderListCollectionVw.frame.size.width, height: 80.0)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case orderListCollectionVw:
            let vc = HelpCenterDetailsVC.instantiate()
            vc.selectedProduct = self.productList[indexPath.row]
            vc.selectedOrder = self.orderList[indexPath.row]
            vc.status = self.orderStatusLbl.text
            vc.subTitle = self.orderStatusLbl.text
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}
