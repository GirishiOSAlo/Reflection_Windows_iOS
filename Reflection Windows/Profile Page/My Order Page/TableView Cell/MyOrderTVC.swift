//
//  MyOrderTVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/04/24.
//

import UIKit
import moa

class MyOrderTVC: UITableViewCell {

    static let indentifier = "MyOrderTVC"
    static func nib() -> UINib{
        return UINib(nibName: "MyOrderTVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var statusImgVw: UIImageView!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var statusTitleLbl: UILabel!
    @IBOutlet weak var statusSubLbl: UILabel!

    @IBOutlet weak var productBaseView: UIView!
    @IBOutlet weak var imgShadowVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var itemsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initUI() {
        self.baseView.layer.cornerRadius = 12.0
        self.productBaseView.layer.cornerRadius = 12.0
        self.imgVw.layer.cornerRadius = 10.0

        self.imgShadowVw.dropShadow(color: UIColor(hex: "#008BBF", alpha: 0.05), scale: true)
    }
}
