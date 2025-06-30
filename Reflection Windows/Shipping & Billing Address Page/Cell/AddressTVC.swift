//
//  AddressTVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/07/24.
//

import UIKit

class AddressTVC: UITableViewCell {

    static let indentifier = "AddressTVC"
    static func nib() -> UINib{
        return UINib(nibName: "AddressTVC", bundle: nil)
    }

    @IBOutlet weak var addressDetailVw: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phNoLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var selectBtnWidth: NSLayoutConstraint!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var addNewBtn: UIButton!
    
    @IBOutlet weak var defaultAddressLbl: UILabel!
    @IBOutlet weak var defaultAddressLblHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initUI() {
        self.addressDetailVw.layer.cornerRadius = 12.0
        self.addressDetailVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        
        self.addNewBtn.layer.cornerRadius = 16.0
        self.addNewBtn.layer.borderWidth = 1.0
        self.addNewBtn.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
    }
}
