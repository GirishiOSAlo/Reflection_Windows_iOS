//
//  PaymentOptionsVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 21/02/24.
//

import UIKit
import PayPalNativePayments
import SquareInAppPaymentsSDK
import CorePayments
import SVProgressHUD
import PassKit

class PaymentOptionsVC: UIViewController, XIBed {

    static func instantiate(orderPlaceApi: OrderPlaceAPIProtocol, finalAmount: String) -> Self {
        let vc = Self.instantiate()
        vc.orderPlaceApi = orderPlaceApi
        vc.finalAmount = finalAmount
        return vc
    }
    
    var orderPlaceApi: OrderPlaceAPIProtocol?
    var orderPlaceResult: OrderPlaceResult?

    var finalAmount: String = ""
    var shippingAddressId = 0
    var shippingOptionId = 0
    var billingAddressId = 0
    var isWarrentyExtended = 0
    var orderId: Int = 0

    @IBOutlet weak var listCollectionVw: UICollectionView!
    var selectedIndex = 0
    var imgArr = ["ic_paypal","ic_square","ic_applePay"]//["ic_cod","ic_paypal","ic_square","ic_applePay"]
    var titleArr = ["PayPal","Square","Apple Pay"]//["Cash on delivery","PayPal","Square","Apple Pay"]
    var paymentType: String = "paypal"//"cash"
    var paymentPlateform: String = ""
    @IBOutlet weak var proceedBtn: UIButton!
    
    var paypalAccessToken: String = ""
    var paypalOrderId: String = ""
    var payPalClient: PayPalNativeCheckoutClient?
    var applePayToken: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.endEditing(true)
    }
    
    func setupUI() {
        
        self.proceedBtn.layer.cornerRadius = self.proceedBtn.frame.size.height/2
        
        listCollectionVw.register(PaymentOptionsCVC.nib(), forCellWithReuseIdentifier: PaymentOptionsCVC.identifier)
        listCollectionVw.delegate = self
        listCollectionVw.dataSource = self

        
        payPalClient = PayPalNativeCheckoutClient(config: CoreConfig(clientID: Constants.paypalClientId, environment: CorePayments.Environment.sandbox))
        payPalClient?.delegate = self
        
    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onProceedBtnTap(_ sender: UIButton) {
        print("Payment Proceed Button...")
        if self.paymentType.elementsEqual("card") {
            showCardEntryForm()
        } else if self.paymentType.elementsEqual("apple pay") {
            self.requestApplePayAuthorization()
        } else {
            self.showAlert(title: "Alert!", message: "Coming Soon...")
            //self.orderPlaceApiCall(nonce: "")
        }
    }
    
    func orderPlaceApiCall(nonce: String) {
        orderPlaceApi?.getData(shipping_address_id: self.shippingAddressId, shipping_option_id: self.shippingOptionId, billing_address_id: self.billingAddressId, paymentMethod: self.paymentType, extended_warrenty: self.isWarrentyExtended, nonce: nonce, payment_platform: self.paymentPlateform, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            self?.orderPlaceResult = response.data
            
            if isSuccess {
//                if self!.paymentType.elementsEqual("cash") {
//                    let vc = OrderConfirmedPage.instantiate(orderSummaryApi: OrderSummaryAPI())
//                    vc.orderId = self?.orderPlaceResult?.id ?? 0
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
                if self!.paymentType.elementsEqual("paypal") {
                    //PayPal Payment.....
                    self?.orderId = self?.orderPlaceResult?.id ?? 0
                    self?.createPaypalOrder()
                }
                else if self!.paymentType.elementsEqual("card") {
                    //Square Payment.....
                    let vc = OrderConfirmedPage.instantiate(orderSummaryApi: OrderSummaryAPI())
                    vc.orderId = self?.orderPlaceResult?.id ?? 0
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                else if self!.paymentType.elementsEqual("apple pay") {
                    //Apple Pay Payment.....
                    let vc = OrderConfirmedPage.instantiate(orderSummaryApi: OrderSummaryAPI())
                    vc.orderId = self?.orderPlaceResult?.id ?? 0
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
        
    func getAccessToken() -> String {
        let credentials = "\(Constants.paypalClientId):\(Constants.paypalClientSecret)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        
        let tokenurl = URL(string: Constants.paypalBaseURL + "v1/oauth2/token")!
        var request = URLRequest(url: tokenurl)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        
        var accessToken: String?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    self.paypalAccessToken = token
                    accessToken = token
                }
            } catch {
                print("Error parsing access token response: \(error)")
            }
        }.resume()
        
        semaphore.wait()
        
        return accessToken ?? ""
    }
        
    func createPaypalOrder() {
        let currencyCode = "USD" // Custom function to determine currency
        let amountValue = self.orderPlaceResult?.orderAmount ?? ""
        let finalAmount = amountValue.replacingOccurrences(of: ",", with: "")

        let parameters = """
        {
            "application_context": {
                "brand_name": "Reflection Window",
                "return_url": "\(Constants.paypalReturnURL)",
                "shipping_preference": "NO_SHIPPING",
                "user_action": "PAY_NOW"
            },
            "intent": "CAPTURE",
            "purchase_units": [
                {
                    "amount": {
                        "currency_code": "\(currencyCode)",
                        "value": "\(finalAmount)"
                    },
                    "shipping": {
                        "address": {
                            "address_line_1": "A-1 Water Wagon",
                            "address_line_2": "A-1 Water Wagon",
                            "admin_area_1": "Ny",
                            "admin_area_2": "Ny",
                            "country_code": "US",
                            "postal_code": "10012"
                        }
                    }
                }
            ]
        }
        """

        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: Constants.paypalBaseURL + "v2/checkout/orders")!,timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("7b92603e-77ed-4896-8e78-5dea2050476a", forHTTPHeaderField: "PayPal-Request-Id")
        request.addValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error!)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                
                let jsonData = responseString.data(using: .utf8)!
                // Parse JSON
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let orderId = json["id"] as? String {
                        print("Order ID: \(orderId)")
                        self.paypalOrderId = orderId
                        // Now you have the order ID, you can use it to make API requests to PayPal
                        DispatchQueue.main.async {
                            let request = PayPalNativeCheckoutRequest(orderID: orderId)
                            Task {
                                // Start the PayPal checkout
                                await self.payPalClient?.start(request: request)
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()   
    }
    
    func callCaptureOrderID(orderID: String) {
        var request = URLRequest(url: URL(string: Constants.paypalBaseURL + "v2/checkout/orders/\(orderID)/capture")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.paypalAccessToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            SVProgressHUD.dismiss()
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            //Show Next Screen.....
            DispatchQueue.main.async {
                let vc = OrderConfirmedPage.instantiate(orderSummaryApi: OrderSummaryAPI())
                vc.orderId = self.orderPlaceResult?.id ?? 0
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        task.resume()
    }
    
}

extension PaymentOptionsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.listCollectionVw:
            return self.titleArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.listCollectionVw:
            let cell = listCollectionVw.dequeueReusableCell(withReuseIdentifier: PaymentOptionsCVC.identifier, for: indexPath) as! PaymentOptionsCVC
            
            if indexPath.row == self.selectedIndex {
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
                cell.baseView.layer.borderWidth = 0.5
            } else {
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
                cell.baseView.layer.borderWidth = 0.0
            }
            
            cell.titleLbl.text = self.titleArr[indexPath.row]
            cell.imgvw.image = UIImage(named: self.imgArr[indexPath.row])
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case listCollectionVw:
            let height = CGFloat(Constants.Is_iPad ? 78.0 : 58.0)
            return CGSize(width: self.listCollectionVw.frame.size.width, height: height)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.listCollectionVw.reloadData()
        
//        if indexPath.row == 0 {
//            self.paymentType = "cash"
//            self.paymentPlateform = "cod"
//        }
        if indexPath.row == 0 {
            self.paymentType = "paypal"
            self.paymentPlateform = "paypal"
        } else if indexPath.row == 1 {  //Square...
            self.paymentType = "card"
            self.paymentPlateform = "square"
        } else if indexPath.row == 2 {  //Square...
            self.paymentType = "apple pay"
            self.paymentPlateform = "apple pay"
        }
    }
    
    func showCardEntryForm() {
        let theme = SQIPTheme()
        
        // Customize the card entry form
        theme.tintColor = UIColor(hex: "#008BBF", alpha: 1)
        theme.saveButtonTitle = "Submit"
        
        let cardEntryForm = SQIPCardEntryViewController(theme: theme)
        cardEntryForm.delegate = self
        
        // The card entry form should always be displayed in a UINavigationController.
        let navigationController = UINavigationController(rootViewController: cardEntryForm)
        
        present(navigationController, animated: true, completion: nil)
    }
}

//MARK: PayPal Delegate Method.....
extension PaymentOptionsVC: PayPalNativeCheckoutDelegate {
    func paypal(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativePayments.PayPalNativeCheckoutResult) {
        print("Paypal Order ID :: \(result.orderID)")
        
        SVProgressHUD.show()
        DispatchQueue.main.async {
            self.callCaptureOrderID(orderID: result.orderID)
        }
    }

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        // handle the error by accessing `error.localizedDescription`
        print("Paypal Did Finish With Error", error)
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func paypalDidCancel(_ payPalClient: PayPalNativeCheckoutClient) {
        // the user canceled
        print("Paypal Cancelled")
    }
    func paypalWillStart(_ payPalClient: PayPalNativeCheckoutClient) {
        // the PayPal paysheet is about to show up. Handle loading views, spinners, etc.
        print("Paypal Paysheet Show Up.")
    }
}

//MARK: Square Delegate Method.....
extension PaymentOptionsVC: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails) async throws {
        print("nonce:", cardDetails.nonce)
        self.dismiss(animated: true)
        if cardDetails.nonce.isEmpty {
            self.showAlert(title: "Error!", message: "The transaction could not be completed. Please try again later.")
        } else {
            self.orderPlaceApiCall(nonce: cardDetails.nonce)
        }
        //        if cardDetails.nonce.elementsEqual("") {
        //            self.showAlert(title: "Error!", message: "The transaction could not be completed. Please try again later.")
        //        } else {
        //            self.orderPlaceApiCall(nonce: cardDetails.nonce)
        //        }
        //        self.orderPlaceApiCall(nonce: cardDetails.nonce)
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        print(status)
        switch status {
        case .canceled:
            print("Transaction was canceled.")
            showAlert(title: "Transaction Canceled", message: "The payment process was canceled.")
        case .success:
            print("Transaction completed successfully.")
            // Optionally handle success confirmation UI
        default:
            print("An unknown status was returned.")
            showAlert(title: "Error", message: "An unknown error occurred.")
        }
        view.endEditing(true)
        self.dismiss(animated: true)
    }
}

extension PaymentOptionsVC {
    func requestApplePayAuthorization() {
        guard SQIPInAppPaymentsSDK.canUseApplePay else {
            self.showAlert(title: "Error!", message: "Apple Pay is not available on this device.")
            return
        }
        let paymentRequest = PKPaymentRequest.squarePaymentRequest(
            // Set to your Apple merchant ID
            merchantIdentifier: Constants.ApplePay.MERCHANT_IDENTIFIER,
            countryCode: "US",
            currencyCode: "USD"
        )

        let amountValue = self.finalAmount
        let finalAmountStr = amountValue.replacingOccurrences(of: ",", with: "")
        
        if let finalAmountDouble = Double(finalAmountStr) {
            // Payment summary information will be displayed on the Apple Pay sheet.
            let merchantLabel = "Enerfina LLC" // Replace with your Merchant Name

            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: merchantLabel, amount: NSDecimalNumber(value: finalAmountDouble))
            ]

            let paymentAuthorizationViewController =
                PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)

            paymentAuthorizationViewController!.delegate = self

            present(paymentAuthorizationViewController!, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Alert", message: "Something went wrong, Please try different item.")
//            print("Failed to convert finalAmountStr to Double")
        }
        
        
    }
}

//MARK: Apple Pay Delegate Method.....
extension PaymentOptionsVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        // Exchange the authorized PKPayment for a nonce.
        let nonceRequest = SQIPApplePayNonceRequest(payment: payment)
        nonceRequest.perform { cardDetails, error in
            if let cardDetails = cardDetails {
                //                self.showAlert(title: "Success", message: "Apple pay nonce : \(cardDetails.nonce)")
                self.applePayToken = "\(cardDetails.nonce)"
                // Send the card nonce to your server to charge the card or store
                // the card on file.
                
                /*
                 MyAPIClient.shared.chargeCard(withNonce: cardDetails.nonce) {
                 transaction, chargeEerror in
                 
                 if let chargeError = chargeError {
                 completion(PKPaymentAuthorizationResult(status: .failure,
                 errors: [chargeError]))
                 }
                 else {
                 completion(PKPaymentAuthorizationResult(status: .success,
                 errors: nil))
                 }
                 }
                 */
                
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } else if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            print("Nonce: ", self.applePayToken)
            if self.applePayToken.elementsEqual("") {
                self.showAlert(title: "Error!", message: "The transaction could not be completed. Please try again later.")
            } else {
                self.orderPlaceApiCall(nonce: self.applePayToken)
            }
        }
    }
}

// MARK: - Order Place  API Protocol
protocol OrderPlaceAPIProtocol {
    func getData(shipping_address_id: Int, shipping_option_id: Int, billing_address_id: Int, paymentMethod: String, extended_warrenty: Int, nonce: String, payment_platform: String, completion: @escaping ((OrderPlaceDataModel?) -> Void))
}

struct OrderPlaceAPI: OrderPlaceAPIProtocol {
    func getData(shipping_address_id: Int, shipping_option_id: Int, billing_address_id: Int, paymentMethod: String, extended_warrenty: Int, nonce: String, payment_platform: String, completion: @escaping ((OrderPlaceDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .placeOrder(shipping_address_id: shipping_address_id, shipping_option_id: shipping_option_id, billing_address_id: billing_address_id, paymentMethod: paymentMethod, extended_warrenty: extended_warrenty, nonce: nonce, payment_platform: payment_platform)) { (data: OrderPlaceDataModel?) in
            completion(data)
        }
    }
}
