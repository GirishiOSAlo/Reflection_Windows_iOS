//
//  FAQsMainCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 10/09/24.
//

import UIKit

class FAQsMainCVC: UICollectionViewCell {

    static let identifier = "FAQsMainCVC"
    static func nib() -> UINib{
        return UINib(nibName: "FAQsMainCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var sectionTitleLbl: UILabel!
    @IBOutlet weak var sectionTitleLblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var detailsCollectionVw: UICollectionView!
    var faqs: [FAQ] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        self.baseView.layer.cornerRadius = 20.0
        
        detailsCollectionVw.register(FAQsCVC.nib(), forCellWithReuseIdentifier: FAQsCVC.identifier)
        detailsCollectionVw.delegate = self
        detailsCollectionVw.dataSource = self

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

extension FAQsMainCVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.detailsCollectionVw:
            return self.faqs.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.detailsCollectionVw:
            let cell = detailsCollectionVw.dequeueReusableCell(withReuseIdentifier: FAQsCVC.identifier, for: indexPath) as! FAQsCVC
            
            let obj = self.faqs[indexPath.row]
            cell.titleLbl.text = obj.questions ?? ""
            cell.descLbl.text = obj.answers ?? ""
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case detailsCollectionVw:
            
            let obj = self.faqs[indexPath.row]
            
            let title = obj.questions ?? ""
            let titleLblHeight = self.heightForView(text: title, font: UIFont(name: "Poppins-Medium", size: Constants.Is_iPad ? 25.0 : 17.0) ?? UIFont.systemFont(ofSize: 17), width: self.detailsCollectionVw.frame.width - CGFloat(Constants.Is_iPad ? 20.0 : 10.0))
            
            let desc = obj.answers ?? ""
            let descLblHeight = self.heightForView(text: desc, font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 22.0 : 15.0) ?? UIFont.systemFont(ofSize: 15), width: self.detailsCollectionVw.frame.width - CGFloat(Constants.Is_iPad ? 30.0 : 15.0))
            
            let finalHeight = titleLblHeight + descLblHeight + CGFloat(Constants.Is_iPad ? 60.0 : 30.0)
            
            return CGSize(width: self.detailsCollectionVw.frame.size.width, height: finalHeight)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}
