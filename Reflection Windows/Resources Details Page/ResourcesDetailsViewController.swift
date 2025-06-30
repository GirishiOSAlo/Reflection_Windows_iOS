//
//  ResourcesDetailsViewController.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/02/24.
//

import UIKit
import AVKit
import AVFoundation
import SVProgressHUD

class ResourcesDetailsViewController: UIViewController, XIBed, UITextFieldDelegate {
    
    static func instantiate(resourcesApi: ResourcesAPIProtocol,faqApi: FAQAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.resourcesApi = resourcesApi
        vc.faqApi = faqApi
        return vc
    }
    
    var faqApi: FAQAPIProtocol?
    var faqDetails: [FAQData] = []
    var OrgfaqDetails: [FAQData] = []
    var showFAQList: [FAQ] = []
    @IBOutlet weak var faqTopVw: UIView!
    @IBOutlet weak var faqCollectionVw: UICollectionView!
    @IBOutlet weak var faqCollectionVwHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var faqMainVw: UIView!
    @IBOutlet weak var faqMainVwTopConst: NSLayoutConstraint!
    @IBOutlet weak var faqInsideVw: UIView!
    
    var resourcesApi: ResourcesAPIProtocol?
    var resourcesCatArr: [ResourcesCatData] = []
    var resourcesList: [ResourceCatDetail] = []

    @IBOutlet weak var searchBaseVw: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var categoryTblVw: UITableView!
    @IBOutlet weak var categoryCollectionVw: UICollectionView!
    
    @IBOutlet weak var noVideosView: UIView!
    var documentInteractionController: UIDocumentInteractionController!
    @IBOutlet weak var faqTblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.fetchFAQData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.faqMainVwTopConst.constant = self.view.frame.size.height
        self.view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: categoryCollectionVw) // Convert touch to collectionView coordinates
        
        if let indexPath = categoryCollectionVw.indexPathForItem(at: touchPoint) {
            print("Touched cell at indexPath: \(indexPath)")
        } else {
            print("Touch not on a cell")
        }
    }
    
    func setupUI() {
        self.faqCollectionVwHeight.constant = 0.0
        DispatchQueue.main.async {
            self.faqInsideVw.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
            self.faqInsideVw.layoutIfNeeded()
            
            self.faqTopVw.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
            self.faqTopVw.layoutIfNeeded()
            self.faqTopVw.dropShadow(color: .black)
        }
        self.noVideosView.isHidden = true
        
        self.searchBaseVw.layer.cornerRadius = Constants.Is_iPad ? self.searchBaseVw.frame.size.height/2 : 15
        self.searchBaseVw.layer.borderWidth = 1.0
        self.searchBaseVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.view.layoutIfNeeded()
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(self.searchTextFieldDidChange(_:)), for: .editingChanged)
        
        registerCell()
        getResourcesData(searchTxt: self.searchTextField.text!)
    }
    
    func registerCell() {
        categoryTblVw.register(ResourcesCatTVC.nib(), forCellReuseIdentifier: ResourcesCatTVC.indentifier)
        categoryTblVw.delegate = self
        categoryTblVw.dataSource = self
        
        categoryCollectionVw.register(ResourcesDetailCVC.nib(), forCellWithReuseIdentifier: ResourcesDetailCVC.identifier)
        categoryCollectionVw.delegate = self
        categoryCollectionVw.dataSource = self
        
        faqCollectionVw.register(HelpCenterShowCVC.nib(), forCellWithReuseIdentifier: HelpCenterShowCVC.identifier)
        faqCollectionVw.delegate = self
        faqCollectionVw.dataSource = self
        
        faqTblVw.register(FaqTVC.nib(), forCellReuseIdentifier: FaqTVC.indentifier)
        faqTblVw.delegate = self
        faqTblVw.dataSource = self
    }
    

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onViewMoreFAQBtn(_ sender: UIButton) {
        print("View All FAQ")
        self.openFaqMenu()
    }
    
    @IBAction func onCloseFAQBtnTap(_ sender: UIButton) {
        self.closeFaqMenu()
    }
    
    func openFaqMenu() {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.faqMainVwTopConst.constant = 0
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.faqTblVw.reloadData()
        }
    }
    
    func closeFaqMenu() {
        self.faqDetails = self.OrgfaqDetails
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.faqMainVwTopConst.constant = self.view.frame.size.height
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.faqTblVw.reloadData()
        }
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        let searchStr = self.searchTextField.text ?? ""
         print("Search Text :: \(searchStr)")
        self.resourcesCatArr = []
        self.resourcesList = []
        self.categoryTblVw.reloadData()
        self.categoryCollectionVw.reloadData()
        DispatchQueue.main.async {
            self.getResourcesData(searchTxt: searchStr)
        }
    }
    
    func getResourcesData(searchTxt: String) {
        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
            }
            showAlert(title: "No Internet Connection", message: "Make sure your device is connected to the internet.")
        }
        else {
            
            SVProgressHUD.show()
            let userDefaults = UserDefaults.standard
            do {
                let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                //print(userDetail)
                
                let baseURL = Constants.baseProductionURL + "resources?"
                let parameters = ["q": "\(searchTxt)"]
                
                var urlComponents = URLComponents(string: baseURL)!
                urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

                guard let url = urlComponents.url else {
                    fatalError("Invalid URL")
                }
                
                
                let headers = ["Content-Type" : "application/json",
                               "Authorization" : "Bearer " + (userDetail.token ?? "")]
                
                //let request = NSMutableURLRequest(url: URL(string: urlStr)!)
                let request = NSMutableURLRequest(url: url)
                
                let config = URLSessionConfiguration.default
                config.httpAdditionalHeaders = headers
                request.httpMethod = "GET"
                let session = URLSession(configuration: config)
                
                print("Resources Detail Endpoint :: \(url)")
                print("Req :: \(request)")
                
                let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                    
                    // Check if Error took place
                    if let error = error {
                        print("Error took place \(error)")
                        return
                    }
                    
                    // Read HTTP Response Status code
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                    }
                    SVProgressHUD.dismiss()
                    if let data = data {
                        do {
                            let res = try JSONDecoder().decode(ResourcesDetailModel.self, from: data)
                            print("--- Entering Response ---")
                            let responseString = String(data: data , encoding: .utf8) ?? ""
                            print("Response :: \(responseString)")
                            
                            self.resourcesCatArr = res.data?.resources ?? []
                            self.resourcesList = res.data?.resources?[0].resources ?? []
                            DispatchQueue.main.async {
                                if self.resourcesCatArr.count > 0 {
                                    self.noVideosView.isHidden = true
                                } else {
                                    self.noVideosView.isHidden = false
                                }
                                self.categoryTblVw.reloadData()
                                self.categoryCollectionVw.reloadData()
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchFAQData() {
        faqApi?.getData(completion: { [weak self] (data) in
            guard let response = data else { return }
            
            if response.statusCode == 200 {
                self?.OrgfaqDetails = response.data ?? []
                self?.faqDetails = self?.OrgfaqDetails ?? []
                
                if self?.faqDetails[0].faqs?.count ?? 0 > 0 {
                    let faqs = self?.faqDetails[0].faqs ?? []
                    for faq in faqs {
                        if (self?.showFAQList.count ?? 0) < 2 {
                            self?.showFAQList.append(faq)
                        } else {
                            print("not append")
                        }
                    }
                }
                self?.faqCollectionVw.reloadData()
                self?.faqTblVw.reloadData()
                self?.updateFaqBottomView(FAQList: self?.showFAQList ?? [])
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "Error")
            }
        })
    }
    
    func updateFaqBottomView(FAQList: [FAQ]) {
        var collectionHeight = 0.0
        if FAQList.count > 0 {
            for faq in FAQList {
                let question = faq.questions ?? ""
//                let lblHeight = self.heightForView(text: question, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 20.0 : 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 125.0 : 70.0))
                let lblHeight = self.heightForView(text: question, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 125.0 : 70.0))
                let margin = Constants.Is_iPad ? 50.0 : 30.0
                collectionHeight = collectionHeight + lblHeight + margin
                self.faqCollectionVwHeight.constant = collectionHeight
            }
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

//MARK: UICollectionview Delegate Method.....
extension ResourcesDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.faqCollectionVw:
            return self.showFAQList.count
            
        case self.categoryCollectionVw:
            return self.resourcesList.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.faqCollectionVw:
            let cell = faqCollectionVw.dequeueReusableCell(withReuseIdentifier: HelpCenterShowCVC.identifier, for: indexPath) as! HelpCenterShowCVC
            cell.titleLbl.text = self.showFAQList[indexPath.row].questions ?? ""
            return cell
            
        case self.categoryCollectionVw:
            let cell = categoryCollectionVw.dequeueReusableCell(withReuseIdentifier: ResourcesDetailCVC.identifier, for: indexPath) as! ResourcesDetailCVC
            let resource = self.resourcesList[indexPath.row]
            cell.titleLbl.text = resource.name ?? ""
            cell.imgVw.moa.url = resource.image ?? ""
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case self.faqCollectionVw:
            let question = showFAQList[indexPath.row].questions ?? ""
            let lblHeight = self.heightForView(text: question, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 18.0 : 14.0) ?? UIFont.systemFont(ofSize: 14), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 125.0 : 70.0))
            let margin = Constants.Is_iPad ? 50.0 : 30.0
            let cellHeight = lblHeight + margin
            return CGSize(width: self.faqCollectionVw.frame.size.width, height: cellHeight)
            
        case categoryCollectionVw:
            if Constants.Is_iPad {
                let width = (self.categoryCollectionVw.frame.size.width - 10) / 3
                return CGSize(width: width, height: width)
            } else {
                let width = (self.categoryCollectionVw.frame.size.width - 5) / 2
                return CGSize(width: width, height: width)
            }
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case faqCollectionVw:
            break
            
        case categoryCollectionVw:
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let videoURL = URL(string: "\(self.resourcesList[indexPath.row].url ?? "")")
                let player = AVPlayer(url: videoURL!)
                player.volume = 1.0
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

//MARK: UITableview Delegate Method.....
extension ResourcesDetailsViewController: UITableViewDelegate, UITableViewDataSource, CollectionViewCellDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == faqTblVw {
            return faqDetails.count
        } else {
            return resourcesCatArr.count
        }// Return the number of sections in your table view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == faqTblVw {
            return faqDetails[section].faqs?.count ?? 0
        } else {
            return 1 // Return the number of rows in each section
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == faqTblVw {
            let cell = faqTblVw.dequeueReusableCell(withIdentifier: FaqTVC .indentifier, for: indexPath) as! FaqTVC
            cell.selectionStyle = .none
            if let faq = faqDetails[indexPath.section].faqs?[indexPath.row] {
                cell.configure(with: faq)
            }
            return cell
        } else {
            let cell = categoryTblVw.dequeueReusableCell(withIdentifier: ResourcesCatTVC .indentifier, for: indexPath) as! ResourcesCatTVC
            
            cell.selectionStyle = .none
            cell.didSelectDelegate = self
            cell.sectionIndex = indexPath.section
            cell.resources = self.resourcesCatArr[indexPath.section].resources ?? []
            cell.categoryCollectionVw.reloadData()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == faqTblVw, let faqCell = cell as? FaqTVC {
               let questions = faqDetails[indexPath.section].faqs ?? []
               
               if indexPath.row == (questions.count - 1) {
                   // Last row → Round bottom corners
                   faqCell.contentVw.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
                   faqCell.stackView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
               } 
            else {
                   // Other rows → No rounding
                   faqCell.contentVw.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0.0)
                   faqCell.stackView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0.0)
               }
               
               faqCell.contentVw.layoutIfNeeded()
               faqCell.answerView.layoutIfNeeded()
           }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == faqTblVw {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.Is_iPad ? 50 : 40))
            headerView.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
            
            // Add corner radius ONLY to the top corners
            headerView.layer.cornerRadius = 12
            headerView.layer.masksToBounds = true
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: headerView.frame.height))
            label.text = faqDetails[section].title
            label.font = UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 18.0 : 14.0) ?? UIFont.systemFont(ofSize: Constants.Is_iPad ? 18.0 : 14.0)
            label.textColor = .white
            headerView.addSubview(label)
            
            return headerView
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.Is_iPad ? 50 : 40))
            headerView.backgroundColor = .clear
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.frame.width, height: headerView.frame.height))
            label.textAlignment = .left
            label.text = self.resourcesCatArr[section].name ?? ""
            label.font = UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 22.0 : 16.0) ?? UIFont.systemFont(ofSize: Constants.Is_iPad ? 22.0 : 16.0)
            headerView.addSubview(label)
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == faqTblVw {
            return Constants.Is_iPad ? 50 : 40
        } else {
            
            let headerTitle = self.resourcesCatArr[section].name ?? ""
            if headerTitle.elementsEqual("") {
                return 0
            } else {
                return Constants.Is_iPad ? 50 : 40 // Return the height of your header view
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == faqTblVw {
            return ((faqDetails[indexPath.section].faqs?[indexPath.row].isExpanded) != false) ? UITableView.automaticDimension : Constants.Is_iPad ? 70 : 60
        } else {
            return Constants.Is_iPad ? 280 : 200
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == faqTblVw {
            print("didSelect?: ",(faqDetails[indexPath.section].faqs?[indexPath.row].isExpanded) ?? false, indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
            
            // Toggle the expanded state
            faqDetails[indexPath.section].faqs?[indexPath.row].isExpanded.toggle()
            
            // Reload the selected row only for smooth animation
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //Open Resources Video.....
    func didSelectItemAtIndex(urlString: String) {
        if let url = URL(string: urlString) {
            let filePath = url.pathExtension
            if filePath == "mp4" {
                SVProgressHUD.show()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    let videoURL = URL(string: urlString)
                    let player = AVPlayer(url: videoURL!)
                    player.volume = 1.0
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                    SVProgressHUD.dismiss()
                }
            }
            else if filePath == "pdf" {
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// MARK: - Resources API Protocol
protocol ResourcesAPIProtocol {
    func getData(completion: @escaping ((ResourcesDetailModel?) -> Void))
}

struct ResourcesAPI: ResourcesAPIProtocol {
    func getData(completion: @escaping ((ResourcesDetailModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .resources) { (data: ResourcesDetailModel?) in
            completion(data)
        }
    }
}

// MARK: - Document Interaction Controller Delegate methods -
extension ResourcesDetailsViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        self
     }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentInteractionController = nil
    }
}
