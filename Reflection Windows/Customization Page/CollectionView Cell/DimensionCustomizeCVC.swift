//
//  DimensionCustomizeCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/02/24.
//

import UIKit

class DimensionCustomizeCVC: UICollectionViewCell {

    static let identifier = "DimensionCustomizeCVC"
    static func nib() -> UINib{
        return UINib(nibName: "DimensionCustomizeCVC", bundle: nil)
    }
    
    @IBOutlet weak var btnMainVw: UIView!
    @IBOutlet weak var addNewBtn: UIButton!
    
    @IBOutlet weak var detailsVw: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var widthLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        addNewBtn.layer.cornerRadius = self.addNewBtn.frame.size.height/2
        addNewBtn.layer.borderWidth = 1.0
        addNewBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        
        self.detailsVw.layer.cornerRadius = 12.0
    }

}
