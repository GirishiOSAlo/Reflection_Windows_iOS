//
//  HelpCenterProductDetailsTVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 14/06/24.
//

import UIKit

class HelpCenterProductDetailsTVC: UITableViewCell {
    
    static let indentifier = "HelpCenterProductDetailsTVC"
    static func nib() -> UINib{
        return UINib(nibName: "HelpCenterProductDetailsTVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var productImgVw: UIImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var productSubTitleLbl: UILabel!
    @IBOutlet weak var rateView: StarRateView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initui()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initui() {
        self.baseView.layer.cornerRadius = 8.0
    }
}
