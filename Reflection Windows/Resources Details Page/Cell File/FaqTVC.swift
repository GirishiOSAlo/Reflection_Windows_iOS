//
//  FaqTVC.swift
//  Reflection Windows
//
//  Created by Pranay Barua on 04/02/25.
//

import UIKit

class FaqTVC: UITableViewCell {
    static let indentifier = "FaqTVC"
    static func nib() -> UINib{
        return UINib(nibName: "FaqTVC", bundle: nil)
    }
    
    @IBOutlet weak var contentVw: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var expandIconView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerLabel.isHidden = true // Initially hidden
    }

    func configure(with faq: FAQ) {
        questionLabel.text = faq.questions
        questionLabel.isHidden = false
        answerLabel.text = faq.answers
        answerLabel.isHidden = !faq.isExpanded
        answerView.isHidden = !faq.isExpanded
        expandIconView.image = faq.isExpanded ? UIImage(named: "ic_upArrow") : UIImage(named: "ic_downArrow")
    }
}
