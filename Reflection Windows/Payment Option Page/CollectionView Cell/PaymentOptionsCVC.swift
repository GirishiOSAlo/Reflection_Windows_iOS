//
//  PaymentOptionsCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 21/02/24.
//

import UIKit

class PaymentOptionsCVC: UICollectionViewCell {

    static let identifier = "PaymentOptionsCVC"
    static func nib() -> UINib{
        return UINib(nibName: "PaymentOptionsCVC", bundle: nil)
    }

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var radioImgVw: UIImageView!
    @IBOutlet weak var imgvw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        baseView.layer.cornerRadius = 12.0
        baseView.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
    }

}
