//
//  DimensionRangeCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 28/08/24.
//

import UIKit

class DimensionRangeCVC: UICollectionViewCell {

    static let identifier = "DimensionRangeCVC"
    static func nib() -> UINib{
        return UINib(nibName: "DimensionRangeCVC", bundle: nil)
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
