//
//  HomeResourcesCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/02/24.
//

import UIKit

class HomeResourcesCVC: UICollectionViewCell {

    static let identifier = "HomeResourcesCVC"
    static func nib() -> UINib{
        return UINib(nibName: "HomeResourcesCVC", bundle: nil)
    }

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.baseView.layer.cornerRadius = 16.0
        self.subView.layer.cornerRadius = 16.0
    }

}
