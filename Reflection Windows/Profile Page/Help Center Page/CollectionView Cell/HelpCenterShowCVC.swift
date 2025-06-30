//
//  HelpCenterShowCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 24/10/24.
//

import UIKit

class HelpCenterShowCVC: UICollectionViewCell {

    static let identifier = "HelpCenterShowCVC"
    static func nib() -> UINib{
        return UINib(nibName: "HelpCenterShowCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initui()
    }

    func initui() {
        self.baseView.layer.cornerRadius = 8.0
        self.baseView.layer.borderWidth = 0.8
        self.baseView.layer.borderColor = UIColor(hex: "#818181", alpha: 1.0).cgColor
    }
}
