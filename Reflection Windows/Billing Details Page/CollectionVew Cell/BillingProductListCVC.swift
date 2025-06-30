//
//  BillingProductListCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 21/02/24.
//

import UIKit

class BillingProductListCVC: UICollectionViewCell {

    static let identifier = "BillingProductListCVC"
    static func nib() -> UINib{
        return UINib(nibName: "BillingProductListCVC", bundle: nil)
    }

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imgShadowVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.imgVw.layer.cornerRadius = 10.0

        
        self.imgShadowVw.layer.shadowColor = UIColor(hex: "#000000", alpha: 0.50).cgColor
        self.imgShadowVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.imgShadowVw.layer.shadowRadius = 4.0
        self.imgShadowVw.layer.shadowOpacity = 0.5
        self.imgShadowVw.layer.masksToBounds = false
        self.imgShadowVw.layer.shadowPath = UIBezierPath(roundedRect: self.imgShadowVw.bounds, cornerRadius: self.imgShadowVw.layer.cornerRadius).cgPath
    }
}
