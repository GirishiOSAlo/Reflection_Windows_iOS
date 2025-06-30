//
//  HomeCategoryCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/02/24.
//

import UIKit

class HomeCategoryCVC: UICollectionViewCell {

    static let identifier = "HomeCategoryCVC"
    static func nib() -> UINib{
        return UINib(nibName: "HomeCategoryCVC", bundle: nil)
    }

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var labelBaseVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var thumbImgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initUI()
    }

    
    func initUI() {
        self.baseView.layer.cornerRadius = 16.0
        self.labelBaseVw.layer.cornerRadius = 8.0
    }
}
