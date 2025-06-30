//
//  FAQsCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 10/09/24.
//

import UIKit

class FAQsCVC: UICollectionViewCell {

    static let identifier = "FAQsCVC"
    static func nib() -> UINib{
        return UINib(nibName: "FAQsCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        self.baseView.layer.cornerRadius = 20.0
    }

}
