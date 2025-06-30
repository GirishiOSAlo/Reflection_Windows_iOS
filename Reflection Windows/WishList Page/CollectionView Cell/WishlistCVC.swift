//
//  WishlistCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 23/02/24.
//

import UIKit

class WishlistCVC: UICollectionViewCell, RatingViewDelegate {
    
    

    static let identifier = "WishlistCVC"
    static func nib() -> UINib{
        return UINib(nibName: "WishlistCVC", bundle: nil)
    }

    @IBOutlet weak var windowImgVw: UIImageView!
    
    @IBOutlet weak var deleteBaseVw: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var detailBaseVw: UIView!
    @IBOutlet weak var starRateView: StarRateView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addToCartBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        if Constants.Is_iPad {
            self.deleteBaseVw.layer.cornerRadius = self.deleteBaseVw.frame.size.height/2
            self.addToCartBtn.layer.cornerRadius = self.addToCartBtn.frame.size.height/2
        } else {
            self.deleteBaseVw.layer.cornerRadius = 15 //self.deleteBaseVw.frame.size.height/2
            self.addToCartBtn.layer.cornerRadius = 15 //self.addToCartBtn.frame.size.height/2
        }
        self.detailBaseVw.layer.cornerRadius = 10.0
        self.windowImgVw.layer.cornerRadius = 16.0
        
        starRateView.delegate = self
        //starRateView.ratingValue = 4
        starRateView.isUserInteractionEnabled = false
    }
    
    func updateRatingFormatValue(_ value: Int, tag: Int) {
        print("Rating : = ", value)
    }

}
