//
//  CustomTabView.swift
//  MintoakBase
//
//  Created by Chaitanya Soni on 15/04/21.
//  Copyright © 2021 Chaitanya Soni. All rights reserved.
//

import UIKit

enum CustomTabViewState {
    case selected
    case unselected
}

protocol CustomTabSelectDelegate: AnyObject {
    func didSelectTab(tab: CustomTabView)
}

@IBDesignable class CustomTabView: UIView, NibLoadable {
    
    weak var delegate: CustomTabSelectDelegate?
    
    var state: CustomTabViewState = .unselected {
        didSet {
            let isStateSelected = state == .selected
            
            if isStateSelected {
                self.imageView.image = UIImage(named: selectedImageName)
            } else {
                self.imageView.image = UIImage(named: imageName)
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBInspectable var imageName: String = "" {
        didSet {
            self.imageView.image = UIImage(named: imageName)
        }
    }
    @IBInspectable var selectedImageName: String = ""
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        setupFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)
    }
    
    
    @objc func tap() {
        delegate?.didSelectTab(tab: self)
    }
}
