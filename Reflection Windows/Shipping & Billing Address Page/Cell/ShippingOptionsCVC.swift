//
//  ShippingOptionsCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 19/02/24.
//

import UIKit

class ShippingOptionsCVC: UICollectionViewCell {

    static let identifier = "ShippingOptionsCVC"
    static func nib() -> UINib{
        return UINib(nibName: "ShippingOptionsCVC", bundle: nil)
    }

    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var radioImgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var subTitleDesLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.baseView.layer.cornerRadius = 12.0
        self.baseView.dropShadow(color: UIColor(hex: "#008BBF", alpha: 0.05), scale: true)
    }
}
