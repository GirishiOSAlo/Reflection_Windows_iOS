//
//  ZipCodeCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 22/04/24.
//

import UIKit

class ZipCodeCVC: UICollectionViewCell {

    static let identifier = "ZipCodeCVC"
    static func nib() -> UINib{
        return UINib(nibName: "ZipCodeCVC", bundle: nil)
    }

    @IBOutlet weak var baseVw: UIView!
    @IBOutlet weak var phoneNoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
