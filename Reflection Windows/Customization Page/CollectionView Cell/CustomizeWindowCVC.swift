//
//  CustomizeWindowCVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/02/24.
//

import UIKit


class CustomizeWindowCVC: UICollectionViewCell {
    
    static let identifier = "CustomizeWindowCVC"
    static func nib() -> UINib{
        return UINib(nibName: "CustomizeWindowCVC", bundle: nil)
    }

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var detailsVw: UIView!
    @IBOutlet weak var radioImgVw: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var imgVwWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceVw: UIView!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var infoBtnWidth: NSLayoutConstraint!
    
    @IBOutlet weak var SwingSideView: UIView!
    @IBOutlet weak var SwingSideViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var leftSwingBaseVw: UIView!
    @IBOutlet weak var leftSwingLbl: UILabel!
    @IBOutlet weak var leftHandSwingBtn: UIButton!
    
    @IBOutlet weak var rightSwingBaseVw: UIView!
    @IBOutlet weak var rightSwingLbl: UILabel!
    @IBOutlet weak var rightHandSwingBtn: UIButton!
    
    @IBOutlet weak var glassOptionBgVw: UIView!
    @IBOutlet weak var glassOptionVw: UIView!
    @IBOutlet weak var glassOptionVwHeight: NSLayoutConstraint!
    
    @IBOutlet weak var optionCollectionVw: UICollectionView!
    //var optionlist:[String] = []
    var subOptions: [SubOption] = []
    var selectedSubOption: [SubOption] = []
    var selectedOptionIndex:[Int] = []
    var newGlassSelection:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        if newGlassSelection {
            self.selectedOptionIndex = []
            self.selectedSubOption = []
            UserDefaults.standard.removeObject(forKey: "subOptions")
            NotificationCenter.default.removeObserver(self, name: .selectedSubOptions, object: nil)
        }
        self.shadowView.layer.cornerRadius = 12.0
        self.baseView.layer.cornerRadius = 12.0
        self.baseView.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.detailsVw.layer.cornerRadius = 12.0
        self.detailsVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        
        self.imgVw.layer.cornerRadius = 8.0
//        self.baseView.dropShadow(color: UIColor(hex: "#008BBF", alpha: 0.05), scale: true)
        
        self.leftSwingBaseVw.layer.cornerRadius = self.leftSwingBaseVw.frame.size.height/2
        self.rightSwingBaseVw.layer.cornerRadius = self.rightSwingBaseVw.frame.size.height/2
        
        registerCell()
        print(userDefaults.isCartEdit)
        print(self.subOptions)
        
        //==> get selected suboption in userdefaults.....
        if let subOptionsData = UserDefaults.standard.data(forKey: "subOptions"),
           let subOptions = try? JSONDecoder().decode([SubOption].self, from: subOptionsData) {
            print(subOptions)
            
            if userDefaults.isCartEdit {
                for (i,obj) in subOptions.enumerated() {
                    
                    let isSelected = obj.selected ?? false
                    
                    if isSelected { //Added
                        self.selectedOptionIndex.append(i)
                        self.selectedSubOption.append(subOptions[i])
                    }
                    else { //Not added
                        print("not selected.")
                    }
                    
                }
                print("Selected Index = \(self.selectedOptionIndex)")
                
            }
            else {
                print("not edit")
                self.selectedOptionIndex = []
                self.selectedSubOption = []
            }
            // Post notification with selectedSubOption data
            NotificationCenter.default.post(name: .selectedSubOptions, object: nil, userInfo: ["selectedSubOptions": self.selectedSubOption])
        }
    }

    func registerCell() {
        optionCollectionVw.register(GlassOptionCVC.nib(), forCellWithReuseIdentifier: GlassOptionCVC.identifier)
        optionCollectionVw.delegate = self
        optionCollectionVw.dataSource = self
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
}

//MARK: CollectionView Delegate Method...
extension CustomizeWindowCVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.optionCollectionVw:
            return self.subOptions.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.optionCollectionVw:
            let cell = optionCollectionVw.dequeueReusableCell(withReuseIdentifier: GlassOptionCVC.identifier, for: indexPath) as! GlassOptionCVC
                        
            let obj = self.subOptions[indexPath.row]
            cell.titleLbl.text = obj.name
            cell.priceView.isHidden = true
            cell.delegate = self
            
            if indexPath.row == self.subOptions.count - 1 {
                cell.underlineVw.isHidden = true
            } else {
                cell.underlineVw.isHidden = false
            }
            
//            if obj.selected ?? false {
//                cell.icCheckImgVw.image = UIImage(named: "ic_selectedCheckbox")
//            } else {
//                cell.icCheckImgVw.image = UIImage(named: "ic_unselectedCheckbox")
//            }
            
            if self.selectedOptionIndex.contains(indexPath.row) {
                cell.icCheckImgVw.image = UIImage(named: "ic_selectedCheckbox")
            } else {
                cell.icCheckImgVw.image = UIImage(named: "ic_unselectedCheckbox")
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont(name: "Poppins-Regular", size: 16.0) ?? UIFont.systemFont(ofSize: 16)
        switch collectionView {
        case optionCollectionVw:
            
            var totalWindowVwHeight = 0.0
            let optionName = self.subOptions[indexPath.row].name ?? ""
            let lblHeight = self.heightForView(text: optionName, font: font, width: self.optionCollectionVw.frame.width - 116.0)
            let cellHeight = lblHeight + 20.0
//            cellHeight = cellHeight + 25.0 //25.0 price view show
            if cellHeight < 45.0 {
                totalWindowVwHeight = 50.0
            } else {
                totalWindowVwHeight = totalWindowVwHeight + cellHeight
            }
            
            return CGSize(width: self.optionCollectionVw.frame.size.width, height: totalWindowVwHeight)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = self.selectedOptionIndex.firstIndex(of: indexPath.row) {
            print("removed.")
            self.selectedOptionIndex.remove(at: index)
            self.selectedSubOption.remove(at: index)
        } else {
            print("added.")
            self.selectedOptionIndex.append(indexPath.row)
            self.selectedSubOption.append(self.subOptions[indexPath.row])
        }
        
        // Post notification with selectedSubOption data
        NotificationCenter.default.post(name: .selectedSubOptions, object: nil, userInfo: ["selectedSubOptions": self.selectedSubOption])
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension Notification.Name {
    static let glassInfoButtonClicked = Notification.Name("glassInfoButtonClicked")
    static let selectedSubOptions = Notification.Name("selectedSubOptions")
}

extension CustomizeWindowCVC: GlassOptionCollectionViewCellDelegate {
    func glassInfoButtonClicked(cell: GlassOptionCVC) {
        if let indexPath = optionCollectionVw.indexPath(for: cell) {
            NotificationCenter.default.post(name: .glassInfoButtonClicked, object: nil, userInfo: ["cell": self, "innerIndexPath": indexPath])
        }
    }
//    func subOptionSelected(cell: GlassOptionCVC) {
//        if let indexPath = optionCollectionVw.indexPath(for: cell) {
//            NotificationCenter.default.post(name: .selectedSubOptions, object: nil, userInfo: ["cell": self, "innerIndexPath": indexPath])
//        }
//    }
}
