//
//  GlassOptionCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 02/09/24.
//

import UIKit

protocol GlassOptionCollectionViewCellDelegate: AnyObject {
    func glassInfoButtonClicked(cell: GlassOptionCVC)
}

class GlassOptionCVC: UICollectionViewCell {

    static let identifier = "GlassOptionCVC"
    static func nib() -> UINib{
        return UINib(nibName: "GlassOptionCVC", bundle: nil)
    }
    
    weak var delegate: GlassOptionCollectionViewCellDelegate?
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var underlineVw: UIView!
    @IBOutlet weak var icCheckImgVw: UIImageView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var infoButton: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        self.baseView.layer.cornerRadius = 12.0
        infoButton.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
    }
    
    @objc func infoButtonClicked() {
        delegate?.glassInfoButtonClicked(cell: self)
    }
}
