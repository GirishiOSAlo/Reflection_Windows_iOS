//
//  MyOrderProductsCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/04/24.
//

import UIKit

class MyOrderProductsCVC: UICollectionViewCell {

    static let identifier = "MyOrderProductsCVC"
    static func nib() -> UINib{
        return UINib(nibName: "MyOrderProductsCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var productMainVw: UIView!
    @IBOutlet weak var productImgVw: UIImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var productSubTitleLbl: UILabel!
    
    @IBOutlet weak var rateMainVw: UIView!
    @IBOutlet weak var rateVwHeight: NSLayoutConstraint!
    @IBOutlet weak var rateView: StarRateView!
    @IBOutlet weak var underlineVw: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
