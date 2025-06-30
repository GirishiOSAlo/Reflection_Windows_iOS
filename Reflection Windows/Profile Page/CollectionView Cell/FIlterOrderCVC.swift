//
//  FIlterOrderCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 26/02/24.
//

import UIKit

class FIlterOrderCVC: UICollectionViewCell {

    static let identifier = "FIlterOrderCVC"
    static func nib() -> UINib{
        return UINib(nibName: "FIlterOrderCVC", bundle: nil)
    }
    
    @IBOutlet weak var radioImgVw: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
