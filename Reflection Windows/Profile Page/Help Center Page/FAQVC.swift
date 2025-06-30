//
//  FAQVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 10/09/24.
//

import UIKit

class FAQVC: UIViewController, XIBed {

//    static func instantiate(faqApi: FAQAPIProtocol) -> Self {
//        let vc = Self.instantiate()
//        vc.faqApi = faqApi
//        return vc
//    }
//    
//    var faqApi: FAQAPIProtocol?
    var faqDetails: [FAQData] = []

    @IBOutlet weak var faqCollectionVw: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchFAQData()
        self.setupUI()
    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func setupUI() {
        print("FAQ Section :: \(self.faqDetails.count)")
        
        faqCollectionVw.register(FAQsMainCVC.nib(), forCellWithReuseIdentifier: FAQsMainCVC.identifier)
        faqCollectionVw.delegate = self
        faqCollectionVw.dataSource = self
    }
    
//    func fetchFAQData() {
//        faqApi?.getData(completion: { [weak self] (data) in
//            guard let response = data else { return }
//            
//            if response.statusCode == 200 {
//                self?.faqDetails = response.data ?? []
//                self?.setupUI()
//            } else {
//                self?.showAlert(title: "Alert", message: response.message ?? "Error")
//            }
//        })
//    }
    
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

extension FAQVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.faqCollectionVw:
            return self.faqDetails.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.faqCollectionVw:
            let cell = faqCollectionVw.dequeueReusableCell(withReuseIdentifier: FAQsMainCVC.identifier, for: indexPath) as! FAQsMainCVC
            
            let obj = self.faqDetails[indexPath.row]
            cell.sectionTitleLbl.text = obj.title ?? ""
            cell.faqs = obj.faqs ?? []
            cell.detailsCollectionVw.reloadData()
            
            let sectionTitle = obj.title ?? ""
            let sectionTitleHeight = self.heightForView(text: sectionTitle, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 40.0 : 20.0))
            if sectionTitleHeight < 45.0 {
                cell.sectionTitleLblHeight.constant = 45.0
            } else {
                cell.sectionTitleLblHeight.constant = sectionTitleHeight
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case faqCollectionVw:
            
            var cellVwHeight = 0.0
            let obj = self.faqDetails[indexPath.row]
            
            let sectionTitle = obj.title ?? ""
            
            var headerHeight = 0.0
            let sectionTitleHeight = self.heightForView(text: sectionTitle, font: UIFont(name: "Poppins-Bold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 40.0 : 20.0))
            if sectionTitleHeight < 45.0 {
                headerHeight = 45.0
            } else {
                headerHeight = sectionTitleHeight
            }
            
            
            let detailsList = obj.faqs ?? []
            for details in detailsList {
                let title = details.questions ?? ""
                let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Medium", size: Constants.Is_iPad ? 25.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 100.0 : 50.0))
                
                let desc = details.answers ?? ""
                let descLblHeight = self.heightForView(text: desc, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 22.0 : 15.0) ?? UIFont.systemFont(ofSize: 15), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 110.0 : 55.0))
                
                let height = titleLblHeight + descLblHeight + CGFloat(Constants.Is_iPad ? 60.0 : 30.0)
                cellVwHeight = cellVwHeight + height
            }
            let finalHeight = headerHeight + cellVwHeight + CGFloat(Constants.Is_iPad ? 40.0 : 20.0)
            
            return CGSize(width: self.faqCollectionVw.frame.size.width, height: finalHeight)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}

// MARK: - Pre Order  API Protocol
protocol FAQAPIProtocol {
    func getData(completion: @escaping ((FAQDataModel?) -> Void))
}

struct FAQAPI: FAQAPIProtocol {
    func getData(completion: @escaping ((FAQDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .faq) { (data:FAQDataModel?) in
            completion(data)
        }
    }
}
