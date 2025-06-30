//
//  ShippingOptionVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 19/02/24.
//

import UIKit

protocol OpenAddressListFromBack: AnyObject {
    func openAddressTab(isBilling: Bool)
}

class ShippingOptionVC: UIViewController, XIBed {
    
    static func instantiate(shippingOptionsApi: ShippingOptionsAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.shippingOptionsApi = shippingOptionsApi
        return vc
    }
    
    var shippingOptionsApi: ShippingOptionsAPIProtocol?
    var shippingOptionsList: [ShippingOptionData] = []
    var selectedShippingAddress: CustomerAddress?
    var customerAddressId = 0
    var shippingOptionId = 0
    
    weak var openAddressDelegate: OpenAddressListFromBack?
    @IBOutlet weak var optionListCollectionVw: UICollectionView!
    var selectedIndex = 0
    @IBOutlet weak var proceedBtn: UIButton!
    var isComeFromAdd = false
    var isBillingAddress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchShippingOptionsData()
    }

    func setupUI() {
        self.proceedBtn.layer.cornerRadius = self.proceedBtn.frame.size.height/2
        
        optionListCollectionVw.register(ShippingOptionsCVC.nib(), forCellWithReuseIdentifier: ShippingOptionsCVC.identifier)
        optionListCollectionVw.delegate = self
        optionListCollectionVw.dataSource = self
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        if self.isComeFromAdd {
            self.openAddressDelegate?.openAddressTab(isBilling: self.isBillingAddress)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onProceedBtnTap(_ sender: UIButton) {
        print("Proceed Button...")
        let vc = ShippingAddressVC.instantiate(addressListApi: AddressListAPI(), deleteAddressApi: DeleteAddressAPI(),addAddressApi: AddAddressAPI())
        vc.isBillingAddress = true
        vc.selectedShippingAddress = self.selectedShippingAddress
        vc.shippingAddressId = self.self.selectedShippingAddress?.id ?? 0
        vc.shippingOptionId = self.shippingOptionId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchShippingOptionsData() {
        shippingOptionsApi?.getData(customerAddressId: self.customerAddressId, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.shippingOptionsList = response.data?.options ?? []
                self?.optionListCollectionVw.reloadData()
                
                self?.shippingOptionId = self?.shippingOptionsList[0].id ?? 0
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }

}

extension ShippingOptionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.optionListCollectionVw:
            return self.shippingOptionsList.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.optionListCollectionVw:
            let cell = optionListCollectionVw.dequeueReusableCell(withReuseIdentifier: ShippingOptionsCVC.identifier, for: indexPath) as! ShippingOptionsCVC
            
            let option = self.shippingOptionsList[indexPath.row]
            cell.titleLbl.text = option.date ?? ""
            
            let amount:String = option.amount ?? ""
            if amount.elementsEqual("") {
                cell.subTitleLbl.text = "FREE"
            } else {
                cell.subTitleLbl.text = "+$\(amount)"
            }
            cell.subTitleDesLbl.text = "- \(option.type ?? "")"
            
            if indexPath.row == self.selectedIndex {
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
        switch collectionView {
        case optionListCollectionVw:
            let height = Constants.Is_iPad ? 110.0 : 70.0
            return CGSize(width: self.optionListCollectionVw.frame.size.width, height: height)

        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.optionListCollectionVw.reloadData()
        
        self.shippingOptionId = self.shippingOptionsList[self.selectedIndex].id ?? 0
    }
}


// MARK: - PaymentOptions API Protocol
protocol ShippingOptionsAPIProtocol {
    func getData(customerAddressId: Int, completion: @escaping ((ShippingOptionDataModel?) -> Void))
}

struct ShippingOptionsAPI: ShippingOptionsAPIProtocol {
    func getData(customerAddressId: Int, completion: @escaping ((ShippingOptionDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .shippingOption(customer_address_id: customerAddressId)) { (data: ShippingOptionDataModel?) in
            completion(data)
        }
    }
}
