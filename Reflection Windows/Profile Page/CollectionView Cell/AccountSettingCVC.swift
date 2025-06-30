//
//  AccountSettingCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/03/24.
//

import UIKit

class AccountSettingCVC: UICollectionViewCell {

    static let identifier = "AccountSettingCVC"
    static func nib() -> UINib{
        return UINib(nibName: "AccountSettingCVC", bundle: nil)
    }
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconImgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var leftArrowImgVw: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.backgroundColor = UIColor.clear
    }

}
