//
//  HelpCenterCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 22/03/24.
//

import UIKit

class HelpCenterCVC: UICollectionViewCell {

    static let identifier = "HelpCenterCVC"
    static func nib() -> UINib{
        return UINib(nibName: "HelpCenterCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseVw: UIView!
    @IBOutlet weak var imgShadowVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var productBaseVw: UIView!
    
    @IBOutlet weak var rateMainVw: UIView!
    @IBOutlet weak var rateVwHeight: NSLayoutConstraint!
    @IBOutlet weak var rateView: StarRateView!
    @IBOutlet weak var underlineVw: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        self.baseVw.layer.cornerRadius = 20.0
        self.productBaseVw.layer.cornerRadius = 20.0
        self.imgVw.layer.cornerRadius = 10.0
        self.imgShadowVw.dropShadow(color: UIColor(hex: "#008BBF", alpha: 0.05), scale: true)
    }

}
