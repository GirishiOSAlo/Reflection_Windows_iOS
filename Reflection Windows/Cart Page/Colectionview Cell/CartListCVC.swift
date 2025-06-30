//
//  CartListCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 16/02/24.
//

import UIKit

class CartListCVC: UICollectionViewCell {

    static let identifier = "CartListCVC"
    static func nib() -> UINib{
        return UINib(nibName: "CartListCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseShadowVw: UIView!
    @IBOutlet weak var baseVw: UIView!

    @IBOutlet weak var productVw: UIView!
    @IBOutlet weak var detailsVw: UIView!
    
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!

    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var quantityMinusBtn: UIButton!
    @IBOutlet weak var quantityplusBtn: UIButton!
    @IBOutlet weak var quantityLbl: UILabel!
    
    @IBOutlet weak var colorBaseVw: UIView!
    @IBOutlet weak var colorVw: UIView!
    @IBOutlet weak var colorNameLbl: UILabel!
    @IBOutlet weak var swingBaseVw: UIView!
    @IBOutlet weak var swingDirectionLbl: UILabel!
    @IBOutlet weak var insectMeshBaseVw: UIView!
    @IBOutlet weak var insectMeshLbl: UILabel!

    @IBOutlet weak var glassBaseVw: UIView!
    @IBOutlet weak var glassLbl: UILabel!
    @IBOutlet weak var glassOptionBaseVw: UIView!
    @IBOutlet weak var glassOptionLbl: UILabel!
    @IBOutlet weak var anchorageBaseVw: UIView!
    @IBOutlet weak var anchorageLbl: UILabel!

    var plusBtnAction: (() -> Void)?
    var minusBtnAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.baseVw.layer.cornerRadius = 20.0
        self.baseShadowVw.layer.cornerRadius = 20.0
        self.imgVw.layer.cornerRadius = 10.0
        self.quantityMinusBtn.layer.cornerRadius = 3.0
        self.quantityplusBtn.layer.cornerRadius = 3.0
        self.quantityLbl.layer.cornerRadius = 3.0
        self.quantityLbl.layer.borderWidth = 0.5
        self.quantityLbl.layer.borderColor = UIColor(hex: "#BEBEBE80", alpha: 1.0).cgColor
        
        self.colorVw.layer.cornerRadius = colorVw.frame.size.width/2
        self.baseShadowVw.backgroundColor = UIColor(hex: "#008BBF", alpha: 0.05)
        
        self.quantityplusBtn.addTarget(self, action: #selector(plusBtnTap(_:)), for: .touchUpInside)
        self.quantityMinusBtn.addTarget(self, action: #selector(minusBtnTap(_:)), for: .touchUpInside)
    }
    
    @objc func plusBtnTap(_ sender: UIButton) {
        plusBtnAction?()
    }
    
    @objc func minusBtnTap(_ sender: UIButton) {
        minusBtnAction?()
    }
}
