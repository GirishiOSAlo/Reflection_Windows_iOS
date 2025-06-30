//
//  WishListCategoryCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 23/02/24.
//

import UIKit

class WishListCategoryCVC: UICollectionViewCell {

    static let identifier = "WishListCategoryCVC"
    static func nib() -> UINib{
        return UINib(nibName: "WishListCategoryCVC", bundle: nil)
    }

    @IBOutlet weak var baseVw: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.baseVw.backgroundColor = UIColor.white
        self.baseVw.layer.cornerRadius = (self.frame.size.height/2) - 12
        self.baseVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
    }

    func isCellSelected() {
        var fontSize = 0.0
        if Constants.Is_iPad {
            fontSize = 20.0
        } else {
            fontSize = 12.0
        }
        self.baseVw.layer.borderWidth = 1.0
        self.categoryLbl.font = UIFont(name: "Poppins-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        self.categoryLbl.textColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func isCellNotSelected() {
        var fontSize = 0.0
        if Constants.Is_iPad {
            fontSize = 20.0
        } else {
            fontSize = 12.0
        }
        self.baseVw.layer.borderWidth = 0
        self.categoryLbl.font = UIFont(name: "Poppins-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        self.categoryLbl.textColor = UIColor.black
    }
}
