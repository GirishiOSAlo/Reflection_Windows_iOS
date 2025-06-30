//
//  TrackOrderCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 03/04/24.
//

import UIKit

class TrackOrderCVC: UICollectionViewCell {

    static let identifier = "TrackOrderCVC"
    static func nib() -> UINib{
        return UINib(nibName: "TrackOrderCVC", bundle: nil)
    }
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imageBaseVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var topProgressLineVw: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        self.imageBaseVw.layer.cornerRadius = self.imageBaseVw.frame.size.width/2
    }
}
