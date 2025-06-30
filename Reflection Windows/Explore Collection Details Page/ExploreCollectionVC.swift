//
//  ExploreCollectionVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 12/02/24.
//

import UIKit
import moa

class ExploreCollectionVC: UIViewController, XIBed {
    
    weak var openDashboardDelegate: OpenDashboardFromBack?
    
    @IBOutlet weak var bgImageVw: UIImageView!
    @IBOutlet weak var thumbImgVw: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var gradientVw: UIView!
    @IBOutlet weak var detailsVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var detailsPopupVw: UIView!
    @IBOutlet weak var detailsTitleLbl: UILabel!
    @IBOutlet weak var detailsSubTitleLbl: UILabel!

    @IBOutlet weak var detailsTextVw: UITextView!
    @IBOutlet weak var detailsPopupStartBtn: UIButton!
    
    var selectedCollection: DashboardCollection?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        self.startButton.layer.cornerRadius = self.startButton.frame.height/2
        self.startButton.layer.borderColor = UIColor(hex: "#FFFFFF", alpha: 1.0).cgColor
        self.startButton.layer.borderWidth = 1.0
        
        self.detailsPopupStartBtn.layer.cornerRadius = self.detailsPopupStartBtn.frame.height/2
        self.detailsPopupStartBtn.layer.borderColor = UIColor(hex: "#FFFFFF", alpha: 1.0).cgColor
        self.detailsPopupStartBtn.layer.borderWidth = 1.0

        
        self.topView.isHidden = false
        self.gradientVw.isHidden = false
        self.detailsVw.isHidden = false
        self.startButton.isHidden = false
        self.detailsPopupVw.isHidden = true
        
        setupData()
        
        DispatchQueue.main.async {
            self.gradientVw.roundCorners(corners: [.topLeft, .topRight], radius: 24.0)
            self.setGradientBackground()
            self.gradientVw.layoutIfNeeded()
        }
    }
    
    func setupData() {
        self.bgImageVw.moa.url = self.selectedCollection?.categoriesThumbnail ?? ""
        self.thumbImgVw.moa.url = self.selectedCollection?.frontimage ?? ""
        self.titleLbl.text = self.selectedCollection?.categoriesName
        self.detailsLbl.text = self.selectedCollection?.shortDescription
        
        self.detailsTitleLbl.text = self.selectedCollection?.categoriesName
        self.detailsTextVw.text = self.selectedCollection?.description ?? ""
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor(hex: "#323232", alpha: 0.04).cgColor
        let colorBottom = UIColor(hex: "#040404", alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.gradientVw.bounds
                
        self.gradientVw.layer.insertSublayer(gradientLayer, at:0)
    }

    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onStartCustomizationBtnta(_ sender: UIButton) {
        print("Start Cusomization...")
        self.topView.isHidden = false
        self.gradientVw.isHidden = false
        self.detailsVw.isHidden = false
        self.startButton.isHidden = false
        self.detailsPopupVw.isHidden = true

        let vc = CustomizationVC.instantiate(windowDataApi: WindowDataAPI())
        vc.isEdit = false
        vc.category_id = selectedCollection?.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func onViewMoreBtnTap(_ sender: UIButton) {
        self.topView.isHidden = true
        self.gradientVw.isHidden = true
        self.detailsVw.isHidden = true
        self.startButton.isHidden = true
        self.detailsPopupVw.isHidden = false
    }
    
    @IBAction func onDetailsPopupBackBtnTap(_ sender: UIButton) {
        self.topView.isHidden = false
        self.gradientVw.isHidden = false
        self.detailsVw.isHidden = false
        self.startButton.isHidden = false
        self.detailsPopupVw.isHidden = true
    }
    
}

