//
//  ShippingAddressVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 19/02/24.
//

import UIKit
import SVProgressHUD

class ShippingAddressVC: UIViewController, XIBed {

    static func instantiate(addressListApi: AddressListAPIProtocol, deleteAddressApi:DeleteAddressAPIProtocol,addAddressApi: AddAddressAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.addressListApi = addressListApi
        vc.deleteAddressApi = deleteAddressApi
        vc.addAddressApi = addAddressApi
        return vc
    }
    
    var addressListApi: AddressListAPIProtocol?
    var deleteAddressApi: DeleteAddressAPIProtocol?
    var addAddressApi: AddAddressAPIProtocol?
    
    var addressListArr: [CustomerAddress] = []
    var selectedShippingAddress: CustomerAddress?
    var shippingOptionId = 0
    var shippingAddressId = 0
    var billingAddressId = 0
    
    var isComeFromProfilePage = false

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressListTblVw: UITableView!
    
    @IBOutlet weak var proceedBtnVwHeight: NSLayoutConstraint!
    @IBOutlet weak var proceedBtn: UIButton!
    
    @IBOutlet weak var emptyAddressVw: UIView!
    @IBOutlet weak var emptyAddressTitleLbl: UILabel!
    @IBOutlet weak var emptyAddressSubTitleLbl: UILabel!
    @IBOutlet weak var addNewBtn: UIButton!

    @IBOutlet weak var deleteMainPopupVw: UIView!
    @IBOutlet weak var deleteSubPopupVw: UIView!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    
    @IBOutlet weak var sameAddCheckImgvw: UIImageView!

    var isBillingAddress = false
    var selectedAddressIndex : Int!
    var customerAddressID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        
        self.addressListArr = []
        self.addressListTblVw.reloadData()
        
        if self.isBillingAddress {
            self.emptyAddressTitleLbl.text = "Enter Billing Address"
            self.emptyAddressSubTitleLbl.text = ""
            self.addNewBtn.setTitle("Enter Billing Address", for: .normal)
            
            self.fetchAddressListData(type: "billing")
        } else {
            self.emptyAddressTitleLbl.text = "Save Your Address"
            self.emptyAddressSubTitleLbl.text = "Add your address to enjoy\nfaster checkout"
            self.addNewBtn.setTitle("+ Add New Address", for: .normal)
            
            self.fetchAddressListData(type: "shipping")
        }
    }
    
    func setupUI() {
        
        if self.isComeFromProfilePage {
            self.proceedBtnVwHeight.constant = 0.0
            self.titleLbl.text = "Address"
        }
        else {
            self.proceedBtnVwHeight.constant = 96.0
            if self.isBillingAddress {
                self.titleLbl.text = "Billing Address"
            } else {
                self.titleLbl.text = "Shipping Address"
            }
        }
        
        self.emptyAddressVw.isHidden = true
        self.sameAddCheckImgvw.image = UIImage(named: "ic_unselectedCheckbox")
        
        self.proceedBtn.layer.cornerRadius = self.proceedBtn.frame.height/2
        self.addNewBtn.layer.cornerRadius = 16.0
        self.addNewBtn.layer.borderWidth = 1.0
        self.addNewBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor

        self.deleteMainPopupVw.isHidden = true
        self.deleteSubPopupVw.layer.cornerRadius = 12.0
        self.registerCell()
    }
    
    func registerCell() {
        addressListTblVw.register(AddressTVC.nib(), forCellReuseIdentifier: AddressTVC.indentifier)
        addressListTblVw.delegate = self
        addressListTblVw.dataSource = self
    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onProceedBtnTap(_ sender: UIButton) {
        if self.isBillingAddress {
            print("Billing Address Proceed Btn Tap...")
            if self.billingAddressId == 0 {
                self.showAlert(title: "Alert", message: "First Select Address")
            } else {
                let vc = BillingDetailsVC.instantiate(billingSummaryApi: BillingSummaryAPI())
                vc.shippingOptionId = self.shippingOptionId
                vc.shippingAddressId = self.shippingAddressId
                vc.billingAddressId = self.billingAddressId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            print("Shipping Address Proceed Btn Tap...")
            if self.customerAddressID == nil {
                self.showAlert(title: "Alert", message: "First Select Address")
            } else {
                let vc = ShippingOptionVC.instantiate(shippingOptionsApi: ShippingOptionsAPI())
                vc.selectedShippingAddress = self.selectedShippingAddress
                vc.customerAddressId = self.customerAddressID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func onSameShippingAddressBtnTap(_ sender: UIButton) {
        self.sameAddCheckImgvw.image = UIImage(named: "ic_selectedCheckbox")
        self.addNewAddressApiCall(type: "billing")
    }
    
    func addNewAddressApiCall(type: String) {
        let obj = self.selectedShippingAddress
        addAddressApi?.getData(name: obj?.name ?? "", email: obj?.email ?? "", mobile_number: obj?.mobileNumber ?? "", pincode: obj?.pincode ?? "", address_line_1: obj?.addressLine1 ?? "", address_line_2: obj?.addressLine2 ?? "", city: obj?.city ?? "", state: obj?.state ?? "", default_address: 0, shipping_billing_address: type, completion: { [weak self] (data) in
            
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.fetchAddressListData(type: "billing")
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    @IBAction func addNewAddressBtnTap(_ sender: UIButton) {
        print("Add New Address Tap")
        let vc = AddAddressVC.instantiate(addAddressApi: AddAddressAPI(), editAddressApi: EditAddressAPI())
        vc.isBillingAddress = self.isBillingAddress
        vc.selectedShippingAddress = self.selectedShippingAddress
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Delete Popup Button Action...
    @IBAction func deletePopupCancelBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
    }
    
    @IBAction func onYesPopupBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
        if self.isBillingAddress {
            self.deleteAddressApiCall(type: "billing", customerAddressId: self.customerAddressID)
        } else {
            self.deleteAddressApiCall(type: "shipping", customerAddressId: self.customerAddressID)
        }
    }
    
    @IBAction func onNoBtnTap(_ sender: UIButton) {
        self.deleteMainPopupVw.isHidden = true
    }

    func fetchAddressListData(type: String) {
        addressListApi?.getData(type: type, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
//                self?.addressListArr = response.data?.customerAddress ?? []
                
                var list = response.data?.customerAddress ?? []
                // Sort the addresses based on defaultAddress
                let sortedAddresses = list.sorted { (a, b) -> Bool in
                    guard let aDefault = a.defaultAddress, let bDefault = b.defaultAddress else {
                        // Handle nil values by placing them at the end
                        return a.defaultAddress != nil
                    }
                    return aDefault > bDefault
                }
                self?.addressListArr = sortedAddresses
                self?.addressListTblVw.reloadData()
                if (self?.addressListArr.count ?? 0) > 0 {
                    self?.emptyAddressVw.isHidden = true
                    
                    //Set default address...
                    if self?.isBillingAddress ?? false {
                        self?.selectedAddressIndex = 0
                        self?.billingAddressId = self?.addressListArr[0].id ?? 0
                        self?.addressListTblVw.reloadData()
                    } else {
                        for address in self?.addressListArr ?? [] {
                            let defaultAddress = address.defaultAddress
                            if defaultAddress == 0 {
                                print("Address is not default")
                            } else {
                                self?.customerAddressID = address.id
                            }
                        }
                    }
                } else {
                    self?.emptyAddressVw.isHidden = false
                }
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func deleteAddressApiCall(type: String, customerAddressId:Int) {
        deleteAddressApi?.getData(type: type, customerAddressID: customerAddressId, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!
            
            if isSuccess {
                SVProgressHUD.show()
                DispatchQueue.main.async {
                    if self!.isBillingAddress {
                        self?.fetchAddressListData(type: "billing")
                    } else {
                        self?.fetchAddressListData(type: "shipping")
                    }
                }
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func addDefaultAddressApiCall(address: CustomerAddress?) {
        addAddressApi?.getData(name: address?.name ?? "", email: address?.email ?? "", mobile_number: address?.mobileNumber ?? "", pincode: address?.pincode ?? "", address_line_1: address?.addressLine1 ?? "", address_line_2: address?.addressLine2 ?? "", city: address?.city ?? "", state: address?.state ?? "", default_address: 1, shipping_billing_address: "shipping", completion: { [weak self] (data) in
            
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.showAlert(title: "Success", message: "Selected Address successfully set as Default Address")
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
}

//MARK: UITableview Delegate Method.....
extension ShippingAddressVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.addressListArr.count > 0 {
            return self.addressListArr.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addressListTblVw.dequeueReusableCell(withIdentifier: AddressTVC .indentifier, for: indexPath) as! AddressTVC
        
        if indexPath.row == self.addressListArr.count {
            cell.addressDetailVw.isHidden = true
            cell.buttonView.isHidden = false
        }
        else {
            cell.addressDetailVw.isHidden = false
            cell.buttonView.isHidden = true
            cell.defaultAddressLbl.isHidden = true
            cell.defaultAddressLblHeight.constant = 0.0
            
            let address = self.addressListArr[indexPath.row]
            cell.nameLbl.text = address.name ?? ""
            cell.phNoLbl.text = address.mobileNumber ?? ""
            
            let fullAddress = "\(address.addressLine1 ?? ""), \(address.addressLine2 ?? "") - \(address.pincode ?? "")"
            cell.addressLbl.text = fullAddress
            
            let defaultAddress = address.defaultAddress
            if defaultAddress == 0 {
                cell.defaultAddressLbl.isHidden = true
                cell.defaultAddressLblHeight.constant = 0.0
            } else {
                cell.defaultAddressLbl.isHidden = false
                cell.defaultAddressLblHeight.constant = Constants.Is_iPad ? 45.0 : 35.0
            }
            
            if self.selectedAddressIndex == nil {
                if defaultAddress == 0 {
                    cell.addressDetailVw.layer.borderWidth = 0.0
                    cell.selectBtn.setImage(UIImage(named: "ic_radioUnselect"), for: .normal)
                } else {
                    self.customerAddressID =  self.addressListArr[indexPath.row].id
                    cell.addressDetailVw.layer.borderWidth = 1.0
                    cell.selectBtn.setImage(UIImage(named: "ic_radioSelect"), for: .normal)
                    self.selectedShippingAddress = self.addressListArr[indexPath.row]
                }
            } else {
                if self.selectedAddressIndex == indexPath.row {
                    cell.addressDetailVw.layer.borderWidth = 1.0
                    cell.selectBtn.setImage(UIImage(named: "ic_radioSelect"), for: .normal)
                    self.selectedShippingAddress = self.addressListArr[indexPath.row]
                } else {
                    cell.addressDetailVw.layer.borderWidth = 0.0
                    cell.selectBtn.setImage(UIImage(named: "ic_radioUnselect"), for: .normal)
                }
            }
        }
        
        if isComeFromProfilePage {
            cell.editBtn.isHidden = false
            cell.selectBtnWidth.constant = 0.0
        } else {
            cell.editBtn.isHidden = true
            cell.selectBtnWidth.constant = Constants.Is_iPad ? 30.0 : 20.0
        }
        
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn(sender:)), for: .touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(tapEditBtn(sender:)), for: .touchUpInside)
        cell.addNewBtn.tag = indexPath.row
        cell.addNewBtn.addTarget(self, action: #selector(tapAddNewAddressBtn(sender:)), for: .touchUpInside)
        cell.selectBtn.tag = indexPath.row
        cell.selectBtn.addTarget(self, action: #selector(tapSelectAddressBtn(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.addressListArr.count {
            return Constants.Is_iPad ? 110.0 : 80.0
        } else {
            return UITableView.automaticDimension
        }
    }
 
    @objc func tapDeleteBtn(sender: UIButton) {
        print("Address Delete at \(sender.tag)")
        self.customerAddressID = self.addressListArr[sender.tag].id ?? 0
        self.deleteMainPopupVw.isHidden = false
    }
    
    @objc func tapEditBtn(sender: UIButton) {
        print("Address Edit at \(sender.tag)")
        let vc = AddAddressVC.instantiate(addAddressApi: AddAddressAPI(), editAddressApi: EditAddressAPI())
        vc.isComeFromProfileEdit = true
        
        vc.isBillingAddress = self.isBillingAddress
        vc.editShippingAddress = self.addressListArr[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    @objc func tapAddNewAddressBtn(sender: UIButton) {
        print("Add New Address Tap")
        let vc = AddAddressVC.instantiate(addAddressApi: AddAddressAPI(), editAddressApi: EditAddressAPI())
        vc.isBillingAddress = self.isBillingAddress
        vc.selectedShippingAddress = self.selectedShippingAddress
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func tapSelectAddressBtn(sender: UIButton) {
        print("Select Address Tap")
        self.selectedAddressIndex = sender.tag
        self.customerAddressID = self.addressListArr[sender.tag].id ?? 0
        self.addressListTblVw.reloadData()
        
        if isComeFromProfilePage {
            self.addDefaultAddressApiCall(address: self.addressListArr[sender.tag])
        }
        else if self.isBillingAddress {
            self.billingAddressId = self.addressListArr[sender.tag].id ?? 0
        }
        else {
            self.shippingAddressId = self.addressListArr[sender.tag].id ?? 0
        }
    }
}

// MARK: - Address List API Protocol
protocol AddressListAPIProtocol {
    func getData(type: String, completion: @escaping ((AddressListDataModel?) -> Void))
}

struct AddressListAPI: AddressListAPIProtocol {
    func getData(type: String, completion: @escaping ((AddressListDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .addressList(type: type)) { (data: AddressListDataModel?) in
            completion(data)
        }
    }
}

// MARK: - Delete Address List API Protocol
protocol DeleteAddressAPIProtocol {
    func getData(type: String, customerAddressID: Int, completion: @escaping ((DeleteAddressDataModel?) -> Void))
}

struct DeleteAddressAPI: DeleteAddressAPIProtocol {
    func getData(type: String, customerAddressID: Int, completion: @escaping ((DeleteAddressDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .deleteAddress(type: type, customer_address_id: customerAddressID)) { (data: DeleteAddressDataModel?) in
            completion(data)
        }
    }
}
