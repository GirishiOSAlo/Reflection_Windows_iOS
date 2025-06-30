//
//  CustomizationVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 15/02/24.
//

import UIKit
import SVProgressHUD
import moa

struct CartProductData: Codable {
    let product_id: Int?
    let left_swing: Int?
    let right_swing: Int?
    let collection_id: Int?
    let dimension: [DimensionData]?
    let customizer: [Int]?
    let sub_options: [Int]?
    let insectMesh: Bool?
}
struct DimensionData: Codable {
    let cartCount: Int?
    let width: String?
    let height: String?
    
    // Define coding keys if needed
    enum CodingKeys: String, CodingKey {
        case cartCount = "cart_count"
        case width
        case height
    }
}



class CustomizationVC: UIViewController, XIBed {
    
    static func instantiate(windowDataApi:WindowDataAPIProtocol) -> Self {
        let vc = Self.instantiate()
        vc.windowDataApi = windowDataApi
        return vc
    }
    
    var windowDataApi: WindowDataAPIProtocol?
    var customizeResult: CustomizeDataResult?
    var windowProductsArr: [CustomizerProduct] = []
    var addInsectMeshArr: [String] = ["Insect Mesh"]
    var glassArr : [CustomizerCategoryDetails] = []
    var colorsArr : [CustomizerCategoryDetails] = []
    var anchorageArr : [CustomizerCategoryDetails] = []
    var dimensionsArr: [CustomizerDimension] = []
    var dimensionInfoDetails: DimensionInfoDetails?
    
    var glassthumbImgArr = ["ic_thumb_SS-01","ic_thumb_SS-02","ic_thumb_DS-01","ic_thumb_TS-01"]
    
    
    var cart_ID: String! = ""
    var category_id: Int!
    var product_id: Int!
    var glass_id: Int!
    var color_id: Int!
    var anchorage_id: Int!
    var glassSubOptions: [Int] = []
    var glassSubOptionsName: [String] = []
    
    struct DimensionDetails {
        var width: String
        var height: String
        var quantity: Int
    }

    var dimensionLimitDetails: [DimensionLimitDetails] = []
    
    @IBOutlet weak var widthRangeBaseVw: UIView!
    @IBOutlet weak var widthRangeCollectionVw: UICollectionView!
    var widthRangeArr: [Double] = []
    
    @IBOutlet weak var heightRangeBaseVw: UIView!
    @IBOutlet weak var heightRangeCollectionVw: UICollectionView!
    var heightRangeArr: [Double] = []

    
    @IBOutlet weak var customizeBaseVw: UIView!
    @IBOutlet weak var nextBtnVw: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollBaseVw: UIView!
    @IBOutlet weak var proceedCartBtnVw: UIView!
    @IBOutlet weak var proceedCartBtn: UIButton!
    @IBOutlet weak var wishButton: UIButton!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    @IBOutlet weak var windowBaseVw: UIView!
    @IBOutlet weak var windowBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var addInsectBaseVw: UIView!
    @IBOutlet weak var addInsectBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var glassBaseVw: UIView!
    @IBOutlet weak var glassBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var colorBaseVw: UIView!
    @IBOutlet weak var colorBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var anchorageBaseVw: UIView!
    @IBOutlet weak var anchorageBaseVwHeight: NSLayoutConstraint!
    @IBOutlet weak var dimensionBaseVw: UIView!
    @IBOutlet weak var dimensionBaseVwHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var windowCollectionVw: UICollectionView!
    var windowSelectedIndex: Int = 0
    var windowTypeIndex: Int = 0
    @IBOutlet weak var addInsectMeshCollectionVw: UICollectionView!
    var selectedAddInsectMeshIndex:[Int] = []
    @IBOutlet weak var glassCollectionVw: UICollectionView!
    var glassSelectedIndex: Int = 0
    @IBOutlet weak var colorCollectionVw: UICollectionView!
    var colorSelectedIndex: Int = 0
    @IBOutlet weak var anchorageCollectionVW: UICollectionView!
    var anchorageSelectedIndex: Int = 0
    @IBOutlet weak var dimensionCollectionVw: UICollectionView!
    
    
    @IBOutlet weak var mainPopupVw: UIView!
    
    @IBOutlet weak var dimensionSubPopupVw: UIView!
    @IBOutlet weak var widthDimentionBaseVw: UIView!
    @IBOutlet weak var widthDimentionTxtField: UITextField!
    @IBOutlet weak var heightDimentionBaseVw: UIView!
    @IBOutlet weak var heightDimentionTxtField: UITextField!
    @IBOutlet weak var quantityDimensionBaseVw: UIView!
    @IBOutlet weak var quantityDimensionMinusBtn: UIButton!
    @IBOutlet weak var quantityDimensionPlsBtn: UIButton!
    @IBOutlet weak var quantityDimensionTxtField: UITextField!
    @IBOutlet weak var dimentionInfoSubVw: UIView!
    @IBOutlet weak var dimensionHeightRangeLbl: UILabel!
    @IBOutlet weak var dimensionWidthRangeLbl: UILabel!
    @IBOutlet weak var dimentionSaveBtn: UIButton!
    @IBOutlet weak var dimensionWidthErrorLbl: UILabel!
    @IBOutlet weak var dimensionHeightErrorLbl: UILabel!
    
    
    @IBOutlet weak var dimensionInfoSubPopupVw: UIView!
    @IBOutlet weak var dimensionInfoPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var dimensionInfoPopupImgVw: UIImageView!
    
    @IBOutlet weak var dimensionInfoPopupTitleLbl: UILabel!
    @IBOutlet weak var dimensionInfoPopupLbl: UILabel!
    
    @IBOutlet weak var windowInfoSubPopupVw: UIView!
    @IBOutlet weak var windowInfoPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var windowInfoPopupTitleLbl: UILabel!
    @IBOutlet weak var windowInfoPopupImgVw: UIImageView!
    @IBOutlet weak var windowinfoPopupImgHeight: NSLayoutConstraint!
    @IBOutlet weak var windowInfoPopupLbl: UILabel!
    @IBOutlet weak var windowInfoPopupLblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var glassInfoSubPopupVw: UIView!
    @IBOutlet weak var glassInfoPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var glassInfoPopupImgVw: UIImageView!
    @IBOutlet weak var glssInfoPopupTitleLbl: UILabel!
    @IBOutlet weak var glassInfoPopupLbl: UILabel!
    
    @IBOutlet weak var glassOptionInfoSubPopupVw: UIView!
    @IBOutlet weak var glassOptionInfoPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var glassOptionInfoPopupImgVw: UIImageView!
    @IBOutlet weak var glssOptionInfoPopupTitleLbl: UILabel!
    @IBOutlet weak var glassOptionInfoPopupLbl: UILabel!
    var glassAlreadySelected = false
    
    @IBOutlet weak var anchorageInfoSubPopupVw: UIView!
    @IBOutlet weak var anchorageInfoPopupVwHeight: NSLayoutConstraint!
    @IBOutlet weak var anchorageInfoPopupImgVw: UIImageView!
    @IBOutlet weak var anchorageInfoPopupTitleLbl: UILabel!
    @IBOutlet weak var anchorageInfoPopupLbl: UILabel!
    
    @IBOutlet weak var swingOptionSubPopupVw: UIView!
    @IBOutlet weak var swingOptionSubPopuvwHeight: NSLayoutConstraint!
    @IBOutlet weak var selectSwingSaveBtn: UIView!
    @IBOutlet weak var leftSwingPopupSubVw: UIView!
    @IBOutlet weak var rightSwingPopupSubVw: UIView!
    @IBOutlet weak var leftSwingRadioImgVw: UIImageView!
    @IBOutlet weak var rightSwingRadioImgVw: UIImageView!
    @IBOutlet weak var leftSwingPopupImgVw: UIImageView!
    @IBOutlet weak var rightSwingPopupImgVw: UIImageView!
    @IBOutlet weak var goToArkitBtn: UIButton!
    
    var totalQuantity: Int = 1
    var isDimensionEdit = false
    var isDimensionEditIndex = 0
    
    var dimensionDetailsArr: [DimensionDetails] = []
    var scrollLastContentOffset: CGFloat = 0
    var isScrollEnabled = true
    var selectOption = 1
    var isComeAddDimension = false
    var windowHandSwing: String = ""
    
    @IBOutlet weak var customizeLeftBtn: UIButton!
    @IBOutlet weak var customizeRightBtn: UIButton!
    
    @IBOutlet weak var baseWindowImgVw: UIImageView!
    @IBOutlet weak var showGlassImgVw: UIImageView!
    @IBOutlet weak var showObsureGlassOptionImgVw: UIImageView!
    @IBOutlet weak var showMuntinsGlassOptionImgVw: UIImageView!
    @IBOutlet weak var showColorImgVw: UIImageView!
    @IBOutlet weak var showSubImageVw: UIImageView!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderStackVw: UIStackView!
    @IBOutlet weak var sliderStackVwWidth: NSLayoutConstraint!
    @IBOutlet weak var leftrightButtonVw: UIView!
    
    var viewArr : [UIView] = []
    var progressBarArr: [UIProgressView] = []
    var progressValue: Float = 0.0
    var totalSteps: Float = 100.0
    var currentIndex = 0
    var isEdit:Bool = false
    var isAddInsectMeshVisible = false
    var addedInsectMesh: Bool = false
    var isSelectedInsectMesh:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userDefaults.isCartEdit = self.isEdit
        self.fetchProductData(categoryID: self.category_id, cartID: self.cart_ID)
    }
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func setupUI() {
        self.scrollVw.delegate = self
        self.baseWindowImgVw.isHidden = false
        self.showGlassImgVw.isHidden = false
        self.showObsureGlassOptionImgVw.isHidden = false
        self.showMuntinsGlassOptionImgVw.isHidden = false
        self.showColorImgVw.isHidden = false
        self.leftrightButtonVw.isHidden = true
        self.showSubImageVw.isHidden = true
        self.customizeLeftBtn.layer.cornerRadius = self.customizeLeftBtn.frame.height/2
        self.customizeRightBtn.layer.cornerRadius = self.customizeRightBtn.frame.height/2
        
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height/2
        self.proceedCartBtn.layer.cornerRadius = self.proceedCartBtn.frame.height/2
        
        self.selectSwingSaveBtn.layer.cornerRadius = self.selectSwingSaveBtn.frame.size.height/2
        self.leftSwingPopupSubVw.layer.cornerRadius = 12.0
        self.leftSwingPopupSubVw.layer.borderWidth = 1.0
        self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
        self.rightSwingPopupSubVw.layer.cornerRadius = 12.0
        self.rightSwingPopupSubVw.layer.borderWidth = 1.0
        self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
        
        self.wishButton.layer.cornerRadius = self.wishButton.frame.height/2
        self.wishButton.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.wishButton.layer.borderWidth = 1.0
        self.goToArkitBtn.layer.cornerRadius = 12.0
        
        self.selectOption = 1
        
        self.nextBtnVw.isHidden = false
        self.proceedCartBtnVw.isHidden = true
        self.mainPopupVw.isHidden = true
        self.dimensionInfoSubPopupVw.isHidden = true
        self.windowInfoSubPopupVw.isHidden = true
        self.glassInfoSubPopupVw.isHidden = true
        self.glassOptionInfoSubPopupVw.isHidden = true
        self.anchorageInfoSubPopupVw.isHidden = true
        self.dimensionSubPopupVw.isHidden = true
        self.swingOptionSubPopupVw.isHidden = true

        DispatchQueue.main.async {
            self.customizeBaseVw.roundCorners(corners: [.topLeft, .topRight], radius: 40.0)
            self.customizeBaseVw.layoutIfNeeded()
        }
        
        registerCell()
        NotificationCenter.default.addObserver(self, selector: #selector(glassInfoButtonClicked(_:)), name: .glassInfoButtonClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedSubOptions(_:)), name: .selectedSubOptions, object: nil)

        
        self.widthRangeBaseVw.layer.cornerRadius = 12.0
        self.widthRangeBaseVw.isHidden = true
        self.heightRangeBaseVw.layer.cornerRadius = 12.0
        self.heightRangeBaseVw.isHidden = true
                
        self.dimensionInfoSubPopupVw.layer.cornerRadius = 12.0
        self.dimensionInfoPopupImgVw.layer.cornerRadius = 12.0
        self.windowInfoSubPopupVw.layer.cornerRadius = 12.0
        self.glassInfoSubPopupVw.layer.cornerRadius = 12.0
        self.glassOptionInfoSubPopupVw.layer.cornerRadius = 12.0
        self.glassInfoPopupImgVw.layer.cornerRadius = 12.0
        self.anchorageInfoSubPopupVw.layer.cornerRadius = 12.0
        self.anchorageInfoPopupImgVw.layer.cornerRadius = 12.0
        self.swingOptionSubPopupVw.layer.cornerRadius = 12.0
        
        self.dimensionSubPopupVw.layer.cornerRadius = 12.0
        self.widthDimentionBaseVw.layer.cornerRadius = 12.0
        self.heightDimentionBaseVw.layer.cornerRadius = 12.0
        self.quantityDimensionBaseVw.layer.cornerRadius = 8.0
        self.quantityDimensionMinusBtn.layer.cornerRadius = 8.0
        self.quantityDimensionPlsBtn.layer.cornerRadius = 8.0
        self.dimentionInfoSubVw.layer.cornerRadius = 8.0
        self.dimentionSaveBtn.layer.cornerRadius = self.dimentionSaveBtn.frame.height/2
        
        self.widthDimentionBaseVw.layer.borderWidth = 1.0
        self.widthDimentionBaseVw.layer.borderColor = UIColor(hex: "#111113", alpha: 0.2).cgColor
        self.heightDimentionBaseVw.layer.borderWidth = 1.0
        self.heightDimentionBaseVw.layer.borderColor = UIColor(hex: "#111113", alpha: 0.2).cgColor
        self.quantityDimensionBaseVw.layer.borderWidth = 1.0
        self.quantityDimensionBaseVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor

        self.widthDimentionTxtField.delegate = self
        self.heightDimentionTxtField.delegate = self
        self.quantityDimensionTxtField.delegate = self
        
        self.widthDimentionTxtField.addTarget(self, action: #selector(self.widthDimentionTxtFieldDidChange(_:)), for: .editingChanged)
        self.heightDimentionTxtField.addTarget(self, action: #selector(self.heightDimentionTxtFieldDidChange(_:)), for: .editingChanged)
        
        self.totalQuantity = 1
        self.widthDimentionTxtField.text = ""
        self.heightDimentionTxtField.text = ""
        self.quantityDimensionTxtField.text = "\(self.totalQuantity)"
                
        self.updateSrollVwHeight(window: 0, insectMesh: 0, glass: 0, color: 0, anchourage: 4, dimension: self.dimensionDetailsArr.count)
    }
    
    func registerCell() {
        windowCollectionVw.register(CustomizeWindowCVC.nib(), forCellWithReuseIdentifier: CustomizeWindowCVC.identifier)
        windowCollectionVw.delegate = self
        windowCollectionVw.dataSource = self
        
        addInsectMeshCollectionVw.register(CustomizeWindowCVC.nib(), forCellWithReuseIdentifier: CustomizeWindowCVC.identifier)
        addInsectMeshCollectionVw.delegate = self
        addInsectMeshCollectionVw.dataSource = self
        
        glassCollectionVw.register(CustomizeWindowCVC.nib(), forCellWithReuseIdentifier: CustomizeWindowCVC.identifier)
        glassCollectionVw.delegate = self
        glassCollectionVw.dataSource = self

        colorCollectionVw.register(CustomizeWindowCVC.nib(), forCellWithReuseIdentifier: CustomizeWindowCVC.identifier)
        colorCollectionVw.delegate = self
        colorCollectionVw.dataSource = self

        anchorageCollectionVW.register(CustomizeWindowCVC.nib(), forCellWithReuseIdentifier: CustomizeWindowCVC.identifier)
        anchorageCollectionVW.delegate = self
        anchorageCollectionVW.dataSource = self
        
        dimensionCollectionVw.register(DimensionCustomizeCVC.nib(), forCellWithReuseIdentifier: DimensionCustomizeCVC.identifier)
        dimensionCollectionVw.delegate = self
        dimensionCollectionVw.dataSource = self
        
        widthRangeCollectionVw.register(DimensionRangeCVC.nib(), forCellWithReuseIdentifier: DimensionRangeCVC.identifier)
        widthRangeCollectionVw.delegate = self
        widthRangeCollectionVw.dataSource = self
        
        heightRangeCollectionVw.register(DimensionRangeCVC.nib(), forCellWithReuseIdentifier: DimensionRangeCVC.identifier)
        heightRangeCollectionVw.delegate = self
        heightRangeCollectionVw.dataSource = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .glassInfoButtonClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .selectedSubOptions, object: nil)
    }
    
    // Handle the notification and extract the selectedSubOptions
    @objc func handleSelectedSubOptions(_ notification: Notification) {
        if let subOptions = notification.userInfo?["selectedSubOptions"] as? [SubOption] {
            let selectedSubOptions: [SubOption] = subOptions
            //Received Selected SubOptions....
            self.glassSubOptions = []
            self.glassSubOptionsName = []
            self.showObsureGlassOptionImgVw.image = UIImage(named: "")
            self.showMuntinsGlassOptionImgVw.image = UIImage(named: "")
            
            let baseURL = self.customizeResult?.baseImageURL ?? ""
            let categoryID = self.windowProductsArr[self.windowSelectedIndex].categoryID ?? 0
            
            for obj in selectedSubOptions {
                self.glassSubOptions.append(obj.id ?? 0)
                self.glassSubOptionsName.append(obj.name ?? "")
                
                let name = obj.name ?? ""
                var obsureGlassURL = ""
                var muntinsGlassURL = ""
                if name.elementsEqual("Add Obscure Glass") {
                    obsureGlassURL = "\(baseURL)\(categoryID)/\(self.product_id ?? 0)/\(self.glass_id ?? 0)/obscure.png"
                    print(obsureGlassURL)
                    self.showObsureGlassOptionImgVw.image = nil
                    self.showObsureGlassOptionImgVw.moa.onSuccess = { image in
                        print("Glass Image successfully loaded!")
                        SVProgressHUD.dismiss()
                        return image
                    }
                    self.showObsureGlassOptionImgVw.moa.onError = { error, response in
                        print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
                        SVProgressHUD.dismiss()
                        self.showObsureGlassOptionImgVw.image = UIImage(named: "")
                    }
                    self.showObsureGlassOptionImgVw.moa.url = obsureGlassURL
                }
                else if name.elementsEqual("Add Muntins") {
                    muntinsGlassURL = "\(baseURL)\(categoryID)/\(self.product_id ?? 0)/\(self.glass_id ?? 0)/\(self.color_id ?? 0)/muntins.png"
                    self.showMuntinsGlassOptionImgVw.image = nil
                    self.showMuntinsGlassOptionImgVw.moa.onSuccess = { image in
                        print("Glass Image successfully loaded!")
                        SVProgressHUD.dismiss()
                        return image
                    }
                    self.showMuntinsGlassOptionImgVw.moa.onError = { error, response in
                        print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
                        SVProgressHUD.dismiss()
                        self.showMuntinsGlassOptionImgVw.image = UIImage(named: "")
                    }
                    self.showMuntinsGlassOptionImgVw.moa.url = muntinsGlassURL
                }
            }
            //print("Glass Sub Option : ",self.glassSubOptions)
        }
    }
    
    @objc func glassInfoButtonClicked(_ notification: Notification) {
        if let outerCell = notification.userInfo?["cell"] as? CustomizeWindowCVC,
           let innerIndexPath = notification.userInfo?["innerIndexPath"] as? IndexPath,
           let outerIndexPath = glassCollectionVw.indexPath(for: outerCell) {
            print("Info Glass Index : \(outerIndexPath.row) & Option Index : \(innerIndexPath.row)")
            // Handle the button click event here
            
            self.mainPopupVw.isHidden = false
            self.glassOptionInfoSubPopupVw.isHidden = false
            
            let obj = self.glassArr[outerIndexPath.row].options?[innerIndexPath.row]
            let title = obj?.name
            
            let instruction = obj?.instruction ?? ""
            let instructionImageURL = obj?.instructionImage ?? ""
            
            self.glssOptionInfoPopupTitleLbl.text = title
            self.glassOptionInfoPopupLbl.text = instruction
            self.glassOptionInfoPopupImgVw.image = UIImage(named: "")
            self.glassOptionInfoPopupImgVw.moa.url = instructionImageURL
            
            //Popup View Height.....
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 350.0 : 68.0)
            var popupVwHeight = 0.0
            let lbl1Height = self.heightForView(text: self.glssOptionInfoPopupTitleLbl.text ?? "", font: UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - leadingTraillingMargin)
            let lbl2Height = self.heightForView(text: self.glassOptionInfoPopupLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 21.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
            
            let vwHeight = self.view.frame.size.height - 200.0
            let finalHeight = lbl1Height + lbl2Height + CGFloat(Constants.Is_iPad ? 385.0 : 250.0)
            if finalHeight > vwHeight {
                popupVwHeight = vwHeight
            } else {
                popupVwHeight = finalHeight
            }
            self.glassOptionInfoPopupVwHeight.constant = popupVwHeight
        }
    }
    
    func updateSrollVwHeight(window:Int, insectMesh:Int, glass:Int, color:Int, anchourage:Int, dimension:Int) {
        let font = UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 22.0 : 16.0) ?? UIFont.systemFont(ofSize: 16)
        
        var totalWindowVwHeight = 0.0
        if window > 0 {
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
            for window in self.windowProductsArr {
                if window.isSwing == 1 { // Swing option visible...
                    let windowName = window.productName ?? ""
                    let width = leadingTraillingMargin - CGFloat(Constants.Is_iPad ? 45.0 : 30.0) //info button hide...
                    let lblHeight = self.heightForView(text: windowName, font: font, width: self.view.frame.width - width)
                    var cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //Lbl stack top bottom + PriceVw height
                    cellHeight = cellHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0) //-25 is price view height
                    
                    let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0 //top bottom padding + priceVw height
                    if cellHeight < imgVwHeigthWithMargin {
                        totalWindowVwHeight = totalWindowVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)//lblheight + basevw Mrgin...78.0
                    } else {
                        totalWindowVwHeight = totalWindowVwHeight + cellHeight + baseVwTopBottomMargin
                    }
                    let swingVwHeight = CGFloat(Constants.Is_iPad ? 60.0 : 40.0)
                    totalWindowVwHeight = totalWindowVwHeight + swingVwHeight
                }
                else {
                    let windowName = window.productName ?? ""
                    let lblHeight = self.heightForView(text: windowName, font: font, width: self.view.frame.width - leadingTraillingMargin)
                    var cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //Lbl stack top bottom + PriceVw height
                    cellHeight = cellHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0) //-25 is price view height
                    
                    let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0 //imgeheigth + top bottom padding
                    if cellHeight < imgVwHeigthWithMargin {
                        totalWindowVwHeight = totalWindowVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)//lblheight + basevw Mrgin...78.0
                    } else {
                        totalWindowVwHeight = totalWindowVwHeight + cellHeight + baseVwTopBottomMargin
                    }
                }
                print("Window Cell Height = \(totalWindowVwHeight)")
            }
        }
        let windowTitleVwHeigth = CGFloat(Constants.Is_iPad ? 120.0 : 80.0)//+80 top vw heigth...
        self.windowBaseVwHeight.constant = totalWindowVwHeight + windowTitleVwHeigth
        
        
        var totalAddInsectMeshVwHeight = 0.0
        var titleMeshVwHeight = 0.0
        if self.isAddInsectMeshVisible {
            if insectMesh > 0 {
                let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
                
                for insectMesh in self.addInsectMeshArr {
                    let addInsectMeshName = insectMesh
                    let lblHeight = self.heightForView(text: addInsectMeshName, font: font, width: self.view.frame.width - leadingTraillingMargin) //180 = i Btn show & +40 thumb image show...
                    let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //46 = price lbl show & top bottom margin...
                    
                    let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                    if cellHeight < imgVwHeigthWithMargin {
                        totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
                    } else {
                        //let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                        let baseVwTopBottomMargin = 30.0
                        totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight + cellHeight + baseVwTopBottomMargin //16 = baseview top bottom margin...
                    }
                    totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight - 25.0 //-25 is price view height
                }
                titleMeshVwHeight = CGFloat(Constants.Is_iPad ? 100.0 : 60.0)//+60 top vw heigth...
            } else {
                print("Add Insect Mesh not visible.")
            }
        }
        let addInsectMeshTitleVwHeigth = titleMeshVwHeight
        self.addInsectBaseVwHeight.constant = totalAddInsectMeshVwHeight + addInsectMeshTitleVwHeigth
        
        var totalGlassVwHeight = 0.0
        var glassOptionHeight = 0.0
        if glass > 0 {
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let thumbImgWidth = CGFloat(Constants.Is_iPad ? 55.0 : 40.0)
            for (index,glass) in self.glassArr.enumerated() {
                
                let glassName = glass.name ?? ""
                let lblHeight = self.heightForView(text: glassName, font: font, width: self.view.frame.width - leadingTraillingMargin + thumbImgWidth) //180 = i Btn show & 40 thumb image hide...
                let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //46 = price lbl hide & top bottom margin...
                
                let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                if cellHeight < imgVwHeigthWithMargin {
                    totalGlassVwHeight = totalGlassVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)//lblheight + basevw Mrgin...78.0
                } else {
                    let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                    totalGlassVwHeight = totalGlassVwHeight + cellHeight + baseVwTopBottomMargin //16 = baseview top bottom margin...
                }
                
//                let displayPrice = glass.displayPrice ?? 0
//                if displayPrice == 0 { //Price Not Display...
//                    totalGlassVwHeight = totalGlassVwHeight - 25.0 //-25 is price view height
//                }
                totalGlassVwHeight = totalGlassVwHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0) //-25 is price view height
                
                if index == self.glassSelectedIndex {
                    //Glass Option View Height.....
                    let subOptionList = self.glassArr[self.glassSelectedIndex].options ?? []
                    for optionObj in subOptionList {
                        let optionName = optionObj.name ?? ""
                        let lblHeight = self.heightForView(text: optionName, font: font, width: self.glassCollectionVw.frame.width - 116.0)
                        let cellHeight = lblHeight + 20.0
                        if cellHeight < 45.0 {
                            glassOptionHeight = glassOptionHeight + 50.0
                        } else {
                            glassOptionHeight = glassOptionHeight + cellHeight
                        }
                    }
                }
            }
        }
        let glassTitleVwHeigth = CGFloat(Constants.Is_iPad ? 120.0 : 80.0)//+80 top vw heigth...
        self.glassBaseVwHeight.constant = totalGlassVwHeight + glassOptionHeight + glassTitleVwHeigth
        
        var totalColorVwHeight = 0.0
        if color > 0 {
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            for color in self.colorsArr {
                let colorName = color.name ?? ""
                let lblHeight = self.heightForView(text: colorName, font: font, width: self.view.frame.width - leadingTraillingMargin) //180 = i Btn hide & imgVw Width +30 increse...
                //let cellHeight = lblHeight + 21.0 //21 = price lbl hide & top bottom margin...
                let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 30.0 : 21.0)
                
                let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                if cellHeight < imgVwHeigthWithMargin {
                    totalColorVwHeight = totalColorVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
                } else {
                    let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                    totalColorVwHeight = totalColorVwHeight + cellHeight + baseVwTopBottomMargin //16 = baseview top bottom margin...
                }
            }
        }
        let colorTitleVwHeigth = CGFloat(Constants.Is_iPad ? 120.0 : 80.0)//+80 top vw heigth...
        self.colorBaseVwHeight.constant = totalColorVwHeight + colorTitleVwHeigth
        
//        self.anchorageBaseVwHeight.constant = CGFloat(anchourage * 78) + 80.0
        var totalAnchorageVwHeight = 0.0
        if anchourage > 0 {
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            for anchorage in self.anchorageArr {
                let anchorageName = anchorage.name ?? ""
                let lblHeight = self.heightForView(text: anchorageName, font: font, width: self.view.frame.width - leadingTraillingMargin) //180 = i Btn show & +40 thumb image show...
                let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //46 = price lbl show & top bottom margin...
                
                let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                if cellHeight < imgVwHeigthWithMargin {
                    totalAnchorageVwHeight = totalAnchorageVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
                } else {
                    let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                    totalAnchorageVwHeight = totalAnchorageVwHeight + cellHeight + baseVwTopBottomMargin //16 = baseview top bottom margin...
                }
                
//                let displayPrice = anchorage.displayPrice ?? 0
//                if displayPrice == 0 { //Price Not Display...
//                    totalAnchorageVwHeight = totalAnchorageVwHeight - 25.0 //-25 is price view height
//                }
                totalAnchorageVwHeight = totalAnchorageVwHeight - 25.0 //-25 is price view height
            }
        }
        let anchorageTitleVwHeigth = CGFloat(Constants.Is_iPad ? 120.0 : 80.0)//+80 top vw heigth...
        self.anchorageBaseVwHeight.constant = totalAnchorageVwHeight + anchorageTitleVwHeigth
        
        
        var collectionHeight = 0.0
        let addDimensionCellHeight = CGFloat(Constants.Is_iPad ? 80.0 : 55.0)
        let diemsnionCellHeight = CGFloat(dimension * (Constants.Is_iPad ? 125 : 95))
        collectionHeight = diemsnionCellHeight + addDimensionCellHeight

        let dimensionTitleVwHeigth = CGFloat(Constants.Is_iPad ? 120.0 : 80.0)//+80 top vw heigth...
        self.dimensionBaseVwHeight.constant = collectionHeight + dimensionTitleVwHeigth //250.0
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
    
    func carosalfunction(isHidden: Bool) {
        if isHidden {
            self.sliderView.isHidden = true
            self.leftrightButtonVw.isHidden = true
        } else {
            self.sliderView.isHidden = false
            self.leftrightButtonVw.isHidden = false
        }
    }
    
    func isWindowProceed() -> Bool {
        let selectedWindow = windowProductsArr[windowSelectedIndex]
        if selectedWindow.isSwing == 1 {
            if (windowProductsArr[windowSelectedIndex].isLeftSelected ?? false) || (windowProductsArr[windowSelectedIndex].isRightSelected ?? false) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    @IBAction func onNextBtnTap(_ sender: UIButton) {
        if selectOption == 1 {
            if self.isWindowProceed() {
                selectOption = 2
                let innerViewFrame = addInsectBaseVw.convert(addInsectBaseVw.bounds, to: scrollVw)
                // Calculate the content offset needed to scroll the inner view to the top
                let desiredOffset = CGPoint(x: 0, y: innerViewFrame.origin.y + 5.0)
                // Set the content offset of the scrollView
                scrollVw.setContentOffset(desiredOffset, animated: true)
                
                //--> Sub image and left right hidden...
                self.sliderView.isHidden = true
                self.leftrightButtonVw.isHidden = true
            } else {
                self.showAlert(title: "Alert", message: "Please select any one swing side.")
            }
        }
        else if selectOption == 2 {
            selectOption = 3
            let innerViewFrame = glassBaseVw.convert(glassBaseVw.bounds, to: scrollVw)
            // Calculate the content offset needed to scroll the inner view to the top
            let desiredOffset = CGPoint(x: 0, y: innerViewFrame.origin.y)
            // Set the content offset of the scrollView
            scrollVw.setContentOffset(desiredOffset, animated: true)
        }
        else if selectOption == 3 {
            selectOption = 4
            let innerViewFrame = colorBaseVw.convert(colorBaseVw.bounds, to: scrollVw)
            // Calculate the content offset needed to scroll the inner view to the top
            let desiredOffset = CGPoint(x: 0, y: innerViewFrame.origin.y)
            // Set the content offset of the scrollView
            scrollVw.setContentOffset(desiredOffset, animated: true)
        }
        else if selectOption == 4 {
            selectOption = 5
            let innerViewFrame = anchorageBaseVw.convert(anchorageBaseVw.bounds, to: scrollVw)
            // Calculate the content offset needed to scroll the inner view to the top
            let desiredOffset = CGPoint(x: 0, y: innerViewFrame.origin.y)
            // Set the content offset of the scrollView
            scrollVw.setContentOffset(desiredOffset, animated: true)
        }
        else if selectOption == 5 {
            selectOption = 6
            let innerViewFrame = dimensionBaseVw.convert(dimensionBaseVw.bounds, to: scrollVw)
            // Calculate the content offset needed to scroll the inner view to the top
            let desiredOffset = CGPoint(x: 0, y: innerViewFrame.origin.y)
            // Set the content offset of the scrollView
            scrollVw.setContentOffset(desiredOffset, animated: true)
        }
        else if selectOption == 6 {
            print("Add Dimension Screen...")
        }
    }
    
    
    @IBAction func onDimensionMainInfoBtnTap(_ sender: UIButton) {
        print("Dimention Main Info Btn...")
        self.mainPopupVw.isHidden = false
        self.dimensionInfoSubPopupVw.isHidden = false
        self.isComeAddDimension = false
        
        let dimensionInstruction = self.dimensionInfoDetails?.dimensionInstructions ?? ""
        let dimensionInstructionImage = self.dimensionInfoDetails?.dimensionInstructionImage ?? ""
        let dimensionInstructionVideo = self.dimensionInfoDetails?.dimensionInstructionVideo ?? ""
        
        self.dimensionInfoPopupImgVw.image = UIImage(named: "")
        self.dimensionInfoPopupImgVw.moa.url = dimensionInstructionImage
        self.dimensionInfoPopupLbl.text = dimensionInstruction
        
        //Popup View Height.....
        var popupVwHeight = 0.0
        
        self.dimensionInfoPopupTitleLbl.text = "Rough Opening Dimension"
        let lbl1Height = self.heightForView(text: self.dimensionInfoPopupTitleLbl.text ?? "", font: UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 405.0 : 107.0))
        let lbl2Height = self.heightForView(text: self.dimensionInfoPopupLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 21.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 350.0 : 68.0))
        
        let vwHeight = self.view.frame.size.height - 200.0
        let finalHeight = lbl1Height + lbl2Height + CGFloat(Constants.Is_iPad ? 305.0 : 213.0)
        if finalHeight > vwHeight {
            popupVwHeight = vwHeight
        } else {
            popupVwHeight = finalHeight
        }
        self.dimensionInfoPopupVwHeight.constant = popupVwHeight
    }
   
    @IBAction func onDimensionInfoPopupCloseBtnTap(_ sender: UIButton) {
        print("Dimension Info Popup Close Btn Tap...")
        if isComeAddDimension {
            self.mainPopupVw.isHidden = false
            self.dimensionInfoSubPopupVw.isHidden = true
            self.dimensionSubPopupVw.isHidden = false
        } else {
            self.mainPopupVw.isHidden = true
            self.dimensionInfoSubPopupVw.isHidden = true
        }
    }
    
    @IBAction func onWindowInfoPopupCloseBtnTap(_ sender: UIButton) {
        print("Window Info Popup Close Btn Tap...")
        self.mainPopupVw.isHidden = true
        self.windowInfoSubPopupVw.isHidden = true
    }
    
    @IBAction func onGlassInfoPopupCloseBtnTap(_ sender: UIButton) {
        print("Glass Info Popup Close Btn Tap...")
        self.mainPopupVw.isHidden = true
        self.glassInfoSubPopupVw.isHidden = true
    }
    
    @IBAction func onAnchorageInfoPopupCloseBtnTap(_ sender: UIButton) {
        print("Glass Info Popup Close Btn Tap...")
        self.mainPopupVw.isHidden = true
        self.anchorageInfoSubPopupVw.isHidden = true
    }
        
    @IBAction func onLeftSideBtnTap(_ sender: UIButton) {
        print("Previous Image Left Side Arrow tap...")
        self.baseWindowImgVw.isHidden = true
        self.showGlassImgVw.isHidden = true
        self.showObsureGlassOptionImgVw.isHidden = true
        self.showMuntinsGlassOptionImgVw.isHidden = true
        self.showColorImgVw.isHidden = true
        self.showSubImageVw.isHidden = false

        let selectedProductImages = self.windowProductsArr[self.windowSelectedIndex].images ?? []
        if currentIndex == 0 {
            self.currentIndex = (selectedProductImages.count - 1)
        } else {
            self.currentIndex = self.currentIndex - 1
        }
        self.updateProgressbar(index: self.currentIndex)
    }
    
    @IBAction func onRightSideBtnTao(_ sender: UIButton) {
        print("Next Image Right Side Arrow tap...")
        self.baseWindowImgVw.isHidden = true
        self.showGlassImgVw.isHidden = true
        self.showObsureGlassOptionImgVw.isHidden = true
        self.showMuntinsGlassOptionImgVw.isHidden = true
        self.showColorImgVw.isHidden = true
        self.showSubImageVw.isHidden = false
        
        let selectedProductImages = self.windowProductsArr[self.windowSelectedIndex].images ?? []
        if currentIndex == (selectedProductImages.count - 1) {
            self.currentIndex = 0
        } else {
            self.currentIndex = self.currentIndex + 1
        }
        self.updateProgressbar(index: self.currentIndex)
    }
    
    @IBAction func onArkitBtnTap(_ sender: UIButton) {
        let vc = ARViewController.instantiate()
        
        let baseURL = self.customizeResult?.baseImageURL ?? ""
        let categoryID = self.windowProductsArr[self.windowSelectedIndex].categoryID ?? 0
        let productUrl = "\(baseURL)\(self.category_id ?? 0)/\(self.product_id ?? 0)/\(self.glass_id ?? 0)/\(self.color_id ?? 0)/ar.usdz"
        vc.productModelURL = productUrl
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func setupSlider(arrayCount: Int) {
        self.viewArr = []
        self.progressBarArr = []
        self.sliderStackVw.removeFullyAllArrangedSubviews()
        
        for _ in 0...arrayCount-1 {
            let vw = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 10))
            vw.clipsToBounds = true
            
            let progressBar = UIProgressView()
            progressBar.frame = CGRect(x: 0, y: 0, width: vw.frame.size.width, height: vw.frame.size.height)
            progressBar.progressTintColor = UIColor(hex: "#FFFFFF", alpha: 1.0) // Set progress color
            progressBar.trackTintColor = UIColor(hex: "#D9D9D9", alpha: 0.6) // Set base color
            progressBarArr.append(progressBar)
            vw.addSubview(progressBar)
            
            sliderStackVw.addArrangedSubview(vw)
            
            let stackWidth = CGFloat(40 * arrayCount-1)
            let viewWidth = self.view.frame.size.width
            
            if stackWidth > viewWidth {
                sliderStackVwWidth.constant = viewWidth
            } else {
                sliderStackVwWidth.constant = vw.frame.size.width * CGFloat(arrayCount-1)
            }
            self.sliderView.layoutIfNeeded()
        }
        
        self.currentIndex = 0
        self.updateProgressbar(index: self.currentIndex)
    }

    func updateProgressbar(index: Int) {
        print("Current Index :: \(index)")
        let selectedProductImageUrl = self.windowProductsArr[self.windowSelectedIndex].images?[index]
        SVProgressHUD.show()
        self.showSubImageVw.image = nil
        self.showSubImageVw.moa.onSuccess = { image in
            print("Glass Image successfully loaded!")
            SVProgressHUD.dismiss()
            return image
        }
        self.showSubImageVw.moa.onError = { error, response in
            print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
            SVProgressHUD.dismiss()
            self.showSubImageVw.image = UIImage(named: "")
        }
        self.showSubImageVw.moa.url = selectedProductImageUrl

        for i in 0...progressBarArr.count - 1 {
            if i <= self.currentIndex {
                self.progressBarArr[i].setProgress(totalSteps, animated: false)
            } else {
                self.progressBarArr[i].setProgress(progressValue, animated: false)
            }
        }
    }
    
    @IBAction func onProceedCartBtnTap(_ sender: UIButton) {
        print("Proceed to Cart Btn Tap...")
        if self.dimensionDetailsArr.count > 0 {
            if self.isWindowProceed() {
                self.addToCartDataApiCall()
            } else {
                self.showAlert(title: "Alert", message: "Please select any one swing side.")
            }
        } else {
            showAlert(title: "Alert", message: "Please select Dimension details.")
        }
    }
    
    @IBAction func onAddWishBtnTap(_ sender: UIButton) {
        print("Add Wish Btn Tap...")
        if Constants.isGuestLogin {
            self.showAlert(title: "Alert", message: "Please log in to add items to your wishlist")
        } else {
            if self.dimensionDetailsArr.count > 0 {
                self.addToWishListApiCall()
            } else {
                showAlert(title: "Alert", message: "Please select Dimension details.")
            }
        }
    }

    func addToCartDataApiCall() {
        var dimensionArr: [DimensionData] = []
        for detail in self.dimensionDetailsArr {
            let obj = DimensionData(cartCount: detail.quantity, width: "\(detail.width)", height: "\(detail.height)")
            dimensionArr.append(obj)
        }
        
        var isLeftSwing = 0
        var isRightSwing = 0
        let selectedWindow = self.windowProductsArr[self.windowSelectedIndex]
        if selectedWindow.isLeftSelected ?? false {
            isLeftSwing = 1
            isRightSwing = 0
        }else if selectedWindow.isRightSelected ?? false {
            isLeftSwing = 0
            isRightSwing = 1
        } else {
            isLeftSwing = 0
            isRightSwing = 0
        }
        
        let customizer: [Int] = [self.glass_id, self.color_id, self.anchorage_id]
        let productData = CartProductData(product_id: self.product_id, left_swing: isLeftSwing, right_swing: isRightSwing, collection_id: self.category_id, dimension: dimensionArr, customizer: customizer, sub_options: self.glassSubOptions, insectMesh: self.addedInsectMesh)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(productData) else {
            print("Failed to encode product data")
            return
        }

        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(title: "Alert", message: "Oops! No Internet Connection")
            }
        }
        else {
            SVProgressHUD.show()
            guard let url = URL(string: Constants.baseProductionURL + "addToCart?cart_id=\(self.cart_ID ?? "")") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let userdefaults = UserDefaults.standard
            do {
                let userDetail = try userdefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                request.setValue("Bearer " + (userDetail.token ?? ""), forHTTPHeaderField: "Authorization")
                //print("URL :: \(url)")
            } catch {
                print(error.localizedDescription)
                //print(error)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("Error:", error)
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                // Check for response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Alert", message: error?.localizedDescription ?? "Invalid response")
                    return
                }
                
                // Parse data 
                SVProgressHUD.dismiss()
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(AddToCartDataModel.self, from: data)
                        //print("Responce: \(res)")
                        let isSuccess: Bool = res.success!
                        DispatchQueue.main.async {
                            if isSuccess {
                                //Push Cart Page
                                if self.isEdit {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    userDefaults.type = 2
                                    let vc = HomeTabBarVC.instantiate()
                                    vc.isComeFromCustomize = true
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            else {
                                self.showAlert(title: "Alert", message: res.message ?? "")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func addToEditCartDataApiCall() {
        var dimensionArr: [DimensionData] = []
        for detail in self.dimensionDetailsArr {
            let obj = DimensionData(cartCount: detail.quantity, width: detail.width, height: detail.height)
            dimensionArr.append(obj)
        }
        
        var isLeftSwing = 0
        var isRightSwing = 0
        let selectedWindow = self.windowProductsArr[self.windowSelectedIndex]
        if selectedWindow.isLeftSelected ?? false {
            isLeftSwing = 1
            isRightSwing = 0
        }else if selectedWindow.isRightSelected ?? false {
            isLeftSwing = 0
            isRightSwing = 1
        } else {
            isLeftSwing = 0
            isRightSwing = 0
        }
        
        let customizer: [Int] = [self.glass_id, self.color_id, self.anchorage_id]
        let productData = CartProductData(product_id: self.product_id, left_swing: isLeftSwing, right_swing: isRightSwing, collection_id: self.category_id, dimension: dimensionArr, customizer: customizer, sub_options: self.glassSubOptions, insectMesh: self.addedInsectMesh)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(productData) else {
            print("Failed to encode product data")
            return
        }

        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(title: "Alert", message: "Oops! No Internet Connection")
            }
        }
        else {
            SVProgressHUD.show()
            guard let url = URL(string: Constants.baseProductionURL + "addToCart?cart_id=\(self.cart_ID ?? "")&proceed=yes") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let userdefaults = UserDefaults.standard
            do {
                let userDetail = try userdefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                request.setValue("Bearer " + (userDetail.token ?? ""), forHTTPHeaderField: "Authorization")
                //            print("URL :: \(url)")
                //            print("Req :: \(request)")
            } catch {
                print(error.localizedDescription)
                //            print(error)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("Error:", error)
                    return
                }
                
                // Check for response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    SVProgressHUD.dismiss()
                    print("Invalid response")
                    return
                }
                
                // Parse data
                SVProgressHUD.dismiss()
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(AddToCartDataModel.self, from: data)
                        //print("Responce: \(res)")
                        let isSuccess: Bool = res.success!
                        DispatchQueue.main.async {
                            if isSuccess {
                                //Push Cart Page
                                if self.isEdit {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    userDefaults.type = 2
                                    let vc = HomeTabBarVC.instantiate()
                                    vc.isComeFromCustomize = true
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            else {
                                self.showAlert(title: "Alert", message: res.message ?? "")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func fetchProductData(categoryID: Int, cartID: String) {
        windowDataApi?.getData(category_id: categoryID, cart_id: cartID, completion: { [weak self] (data) in
            guard let response = data else { return }
            let isSuccess: Bool = response.success!

            if isSuccess {
                self?.customizeResult = response.data
                self?.windowProductsArr = response.data?.products ?? []
                let customizerDetail = response.data?.customizer
                self?.glassArr = customizerDetail?.glass ?? []
                self?.colorsArr = customizerDetail?.colors ?? []
                self?.anchorageArr = customizerDetail?.anchorage ?? []
                self?.dimensionsArr = response.data?.dimensions ?? []
                self?.dimensionInfoDetails = response.data?.dimensionDetails
                
                if self!.isEdit {
                    print("Edit")
                    
                    if self?.windowProductsArr.count ?? 0 > 0 {
                        for i in (0..<(self?.windowProductsArr.count ?? 0)) {
                            let window = self?.windowProductsArr[i]
                            if window?.selected == true {
                                self?.windowSelectedIndex = i
                                
                                //--> Add Insect Mesh hide & show managed...
                                if window?.isInsectMeshVisible ?? false {
                                    self?.isAddInsectMeshVisible = true
                                    if window?.insectMesh ?? false {
                                        self?.addedInsectMesh = true
                                        self?.isSelectedInsectMesh = true
                                        self?.selectedAddInsectMeshIndex.append(0)
                                        
                                    } else {
                                        self?.addedInsectMesh = false
                                        self?.isSelectedInsectMesh = false
                                    }
                                } else {
                                    self?.isAddInsectMeshVisible = false
                                    self?.addedInsectMesh = false
                                    self?.isSelectedInsectMesh = false
                                }
                            }
                            //--> Swing option selection managed...
                            if window?.isLeftSwingSelected == 1 {
                                self?.windowProductsArr[i].isLeftSelected = true
                                self?.windowProductsArr[i].isRightSelected = false
                            }
                            else if window?.isRightSwingSelected == 1 {
                                self?.windowProductsArr[i].isLeftSelected = false
                                self?.windowProductsArr[i].isRightSelected = true
                            }
                            else {
                                self?.windowProductsArr[i].isLeftSelected = false
                                self?.windowProductsArr[i].isRightSelected = false
                            }
                        }
                    }

                    if self?.glassArr.count ?? 0 > 0 {
                        for i in (0..<(self?.glassArr.count ?? 0)) {
                            if self?.glassArr[i].selected == true {
                                self?.glassSelectedIndex = i
                                
                                let subOptions = self?.glassArr[i].options ?? []
                                //==> save selected suboption in userdefaults.....
                                if let encodedSubOptions = try? JSONEncoder().encode(subOptions) {
                                    UserDefaults.standard.set(encodedSubOptions, forKey: "subOptions")
                                } else {
                                    print("glass sub option not found.")
                                }
                            }
                        }
                    }
                    
                    if self?.colorsArr.count ?? 0 > 0 {
                        for i in (0..<(self?.colorsArr.count ?? 0)) {
                            if self?.colorsArr[i].selected == true {
                                self?.colorSelectedIndex = i
                            }
                        }
                    }

                    if self?.anchorageArr.count ?? 0 > 0 {
                        for i in (0..<(self?.anchorageArr.count ?? 0)) {
                            if self?.anchorageArr[i].selected == true {
                                self?.anchorageSelectedIndex = i
                            }
                        }
                    }

                    if self?.dimensionsArr.count ?? 0 > 0 {
                        for obj in self?.dimensionsArr ?? [] {
//                            let dimension = DimensionDetails(width: String(obj.width ?? 0), height: String(obj.height ?? 0), quantity: obj.cartCount ?? 0)
                            let dimension = DimensionDetails(width: obj.width ?? "", height: obj.height ?? "", quantity: obj.cartCount ?? 0)
                            self?.dimensionDetailsArr.append(dimension)
                        }
                    }
                    
                    //=> Show Proceed cart btn...
                    self?.nextBtnVw.isHidden = true
                    self?.proceedCartBtnVw.isHidden = false
                    self?.mainPopupVw.isHidden = true
                    self?.dimensionSubPopupVw.isHidden = true
                    
                    
                }
                else {
                    print("Not Edit")
                    self?.dimensionDetailsArr = []
                    if self?.windowProductsArr.count ?? 0 > 0 {
                        for i in (0..<(self?.windowProductsArr.count ?? 0)) {
                            if self?.windowProductsArr[i].defaultSelected == true {
                                self?.windowSelectedIndex = i
                                
                                //Add Insect Mesh hide & show managed...
                                let window = self?.windowProductsArr[i]
                                if window?.isInsectMeshVisible ?? false {
                                    self?.isAddInsectMeshVisible = true
                                } else {
                                    self?.isAddInsectMeshVisible = false
                                }
                            }
                        }
                    }
                    if self?.glassArr.count ?? 0 > 0 {
                        for i in (0..<(self?.glassArr.count ?? 0)) {
                            if self?.glassArr[i].defaultSelected == true {
                                self?.glassSelectedIndex = i
                            }
                        }
                    }
                    if self?.colorsArr.count ?? 0 > 0 {
                        for i in (0..<(self?.colorsArr.count ?? 0)) {
                            if self?.colorsArr[i].defaultSelected == true {
                                self?.colorSelectedIndex = i
                            }
                        }
                    }
                    if self?.anchorageArr.count ?? 0 > 0 {
                        for i in (0..<(self?.anchorageArr.count ?? 0)) {
                            if self?.anchorageArr[i].defaultSelected == true {
                                self?.anchorageSelectedIndex = i
                            }
                        }
                    }
                }
                
                if self?.windowProductsArr.count ?? 0 > 0 {
                    self?.product_id = self?.windowProductsArr[self?.windowSelectedIndex ?? 0].id ?? 0
                }
                if self?.glassArr.count ?? 0 > 0 {
                    self?.glass_id = self?.glassArr[self?.glassSelectedIndex ?? 0].id ?? 0
                }
                if self?.colorsArr.count ?? 0 > 0 {
                    self?.color_id = self?.colorsArr[self?.colorSelectedIndex ?? 0].id ?? 0
                }
                if self?.anchorageArr.count ?? 0 > 0 {
                    self?.anchorage_id = self?.anchorageArr[self?.anchorageSelectedIndex ?? 0].id ?? 0
                }
                
                self?.windowCollectionVw.reloadData()
                self?.addInsectMeshCollectionVw.reloadData()
                self?.glassCollectionVw.reloadData()
                self?.colorCollectionVw.reloadData()
                self?.anchorageCollectionVW.reloadData()
                self?.dimensionCollectionVw.reloadData()
                self?.updateSrollVwHeight(window: self?.windowProductsArr.count ?? 0, insectMesh: self?.addInsectMeshArr.count ?? 0, glass: self?.glassArr.count ?? 0, color: self?.colorsArr.count ?? 0, anchourage: self?.anchorageArr.count ?? 0, dimension: self?.dimensionDetailsArr.count ?? 0)
                
                //-->Update show image as per selection...
                let baseURL = self?.customizeResult?.baseImageURL ?? ""
                let categoryID = self?.windowProductsArr[self?.windowSelectedIndex ?? 0].categoryID ?? 0
                self?.imageUpdate(baseURL: baseURL, categoryId: categoryID, productId: self?.product_id ?? 0, glassId: self?.glass_id ?? 0, glassOption: self?.glassSubOptionsName ?? [], colorId: self?.color_id ?? 0, glassAlreadySelected: false, isGlassSelection: false)
                
                //--> Set Slider.....
                //self?.setupSlider(arrayCount: self?.windowProductsArr.count ?? 0)
                let selectedProductImages = self?.windowProductsArr[self?.windowSelectedIndex ?? 0].images ?? []
                if selectedProductImages.count > 1 {
                    self?.setupSlider(arrayCount: selectedProductImages.count)
                    self?.leftrightButtonVw.isHidden = false
                } else {
                    self?.leftrightButtonVw.isHidden = true
                }
                
            } else {
                self?.showAlert(title: "Alert", message: response.message ?? "")
            }
        })
    }
    
    func imageUpdate(baseURL: String, categoryId: Int, productId: Int, glassId: Int, glassOption: [String], colorId: Int, glassAlreadySelected: Bool, isGlassSelection: Bool) {
        SVProgressHUD.show()
        let productUrl = "\(baseURL)\(categoryId)/\(productId)/image.png"
        print(productUrl)
        self.baseWindowImgVw.image = nil
        self.baseWindowImgVw.moa.onSuccess = { image in
            print("window Image successfully loaded!")
            SVProgressHUD.dismiss()
            return image
        }
        self.baseWindowImgVw.moa.onError = { error, response in
            print("Failed to load window image: \(String(describing: error?.localizedDescription))")
            SVProgressHUD.dismiss()
            self.baseWindowImgVw.image = UIImage(named: "")
        }
        self.baseWindowImgVw.moa.url = productUrl
        self.windowCollectionVw.reloadData()

        SVProgressHUD.show()
        let glassUrl = "\(baseURL)\(categoryId)/\(productId)/\(glassId)/image.png"
        print(glassUrl)
        self.showGlassImgVw.image = nil
        self.showGlassImgVw.moa.onSuccess = { image in
            print("Glass Image successfully loaded!")
            SVProgressHUD.dismiss()
            return image
        }
        self.showGlassImgVw.moa.onError = { error, response in
            print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
            SVProgressHUD.dismiss()
            self.showGlassImgVw.image = UIImage(named: "")
        }
        self.showGlassImgVw.moa.url = glassUrl
        
        if isGlassSelection {
            if self.glassAlreadySelected {
                print("Glass already select")
            } else {
                self.glassSubOptions = []
                self.glassSubOptionsName = []
                self.showObsureGlassOptionImgVw.image = nil
                self.showMuntinsGlassOptionImgVw.image = nil
                self.glassCollectionVw.reloadData()
            }
        }
        SVProgressHUD.show()
        for objName in self.glassSubOptionsName {
            var obsureGlassURL = ""
            var muntinsGlassURL = ""
            if objName.elementsEqual("Add Obscure Glass") {
                obsureGlassURL = "\(baseURL)\(categoryId)/\(self.product_id ?? 0)/\( self.glass_id ?? 0)/obscure.png"
                //print(glassOptionUrl)
                self.showObsureGlassOptionImgVw.image = nil
                self.showObsureGlassOptionImgVw.moa.onSuccess = { image in
                    print("Glass Option Image successfully loaded!")
                    SVProgressHUD.dismiss()
                    return image
                }
                self.showObsureGlassOptionImgVw.moa.onError = { error, response in
                    print("Failed to load glass option image: \(String(describing: error?.localizedDescription))")
                    SVProgressHUD.dismiss()
                    self.showObsureGlassOptionImgVw.image = UIImage(named: "")
                }
                self.showObsureGlassOptionImgVw.moa.url = obsureGlassURL
            }
            else if objName.elementsEqual("Add Muntins") {
                muntinsGlassURL = "\(baseURL)\(categoryId)/\(self.product_id ?? 0)/\(self.glass_id ?? 0)/\(self.color_id ?? 0)/muntins.png"
//                print(muntinsGlassURL)
                self.showMuntinsGlassOptionImgVw.image = nil
                self.showMuntinsGlassOptionImgVw.moa.onSuccess = { image in
                    print("Glass Option Image successfully loaded!")
                    SVProgressHUD.dismiss()
                    return image
                }
                self.showMuntinsGlassOptionImgVw.moa.onError = { error, response in
                    print("Failed to load glass option image: \(String(describing: error?.localizedDescription))")
                    SVProgressHUD.dismiss()
                    self.showMuntinsGlassOptionImgVw.image = UIImage(named: "")
                }
                self.showMuntinsGlassOptionImgVw.moa.url = muntinsGlassURL
            }
        }

        
        SVProgressHUD.show()
        let colorUrl = "\(baseURL)\(categoryId)/\(productId)/\(glassId)/\(colorId)/image.png"
        print(colorUrl)
        self.showColorImgVw.image = nil
        self.showColorImgVw.moa.onSuccess = { image in
            print("Color Image successfully loaded!")
            SVProgressHUD.dismiss()
            return image
        }
        self.showColorImgVw.moa.onError = { error, response in
            print("Failed to load color image: \(String(describing: error?.localizedDescription))")
            SVProgressHUD.dismiss()
            self.showColorImgVw.image = UIImage(named: "")
        }
        self.showColorImgVw.moa.url = colorUrl
        self.colorCollectionVw.reloadData()
    }
    
    func addToWishListApiCall() {
        var dimensionArr: [DimensionData] = []
        for detail in self.dimensionDetailsArr {
            let obj = DimensionData(cartCount: detail.quantity, width: detail.width, height: detail.height)
            dimensionArr.append(obj)
        }
        
        var isLeftSwing = 0
        var isRightSwing = 0
        let selectedWindow = self.windowProductsArr[self.windowSelectedIndex]
        if selectedWindow.isLeftSelected ?? false {
            isLeftSwing = 1
            isRightSwing = 0
        }else if selectedWindow.isRightSelected ?? false {
            isLeftSwing = 0
            isRightSwing = 1
        } else {
            isLeftSwing = 0
            isRightSwing = 0
        }
        
        let customizer: [Int] = [self.glass_id, self.color_id, self.anchorage_id]
        let productData = CartProductData(product_id: self.product_id, left_swing: isLeftSwing, right_swing: isRightSwing, collection_id: self.category_id, dimension: dimensionArr, customizer: customizer, sub_options: self.glassSubOptions, insectMesh: self.addedInsectMesh)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(productData) else {
            print("Failed to encode product data")
            return
        }

        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(title: "Alert", message: "Oops! No Internet Connection")
            }
        }
        else {
            SVProgressHUD.show()
            guard let url = URL(string: Constants.baseProductionURL + "addToWishlist") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let userDefault = UserDefaults.standard
            do {
                let userDetail = try userDefault.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                request.setValue("Bearer " + (userDetail.token ?? ""), forHTTPHeaderField: "Authorization")
                //            print("URL :: \(url)")
                //            print("Req :: \(request)")
            } catch {
                print(error.localizedDescription)
                //            print(error)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("Error:", error)
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                    return
                }
                
                // Check for response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    SVProgressHUD.dismiss()
                    print("Invalid response")
                    self.showAlert(title: "Error", message: "Invalid response")
                    return
                }
                
                // Parse data
                SVProgressHUD.dismiss()
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(AddToWishlistDataModel.self, from: data)
                        //print("Responce: \(res)")
                        let isSuccess: Bool = res.success!
                        DispatchQueue.main.async {
                            if isSuccess {
                                userDefaults.isWishlistEmpty = false
                                let alert = UIAlertController(title: "Success", message: "Product add to wish list successfully", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { successs in
                                }))
                                self.present(alert, animated: true)
                            }
                            else {
                                self.showAlert(title: "Alert", message: res.message ?? "")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func fetchDimensionApiCall() {
        let collectionID = 2//self.category_id ?? 0
        let windowID = 3//self.product_id ?? 0
        
        if !isConnectionAvailable(){
            if NetWorker.isShowNoInternet{
                NetWorker.isShowNoInternet = false
                showAlert(title: "Alert", message: "Oops! No Internet Connection")
            }
        }
        else {
            SVProgressHUD.show()
            guard let url = URL(string: Constants.baseProductionURL + "getDimensions?window_id=\(windowID)&collection_id=\(collectionID)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let userDefaults = UserDefaults.standard
            do {
                let userDetail = try userDefaults.getObject(forKey: "UserDetailsData", castTo: UserDetails.self)
                request.setValue("Bearer " + (userDetail.token ?? ""), forHTTPHeaderField: "Authorization")
//                print("URL :: \(url)")
//                print("Req :: \(request)")
            } catch {
                print(error.localizedDescription)
                //            print(error)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("Error:", error)
                    return
                }
                
                // Check for response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    SVProgressHUD.dismiss()
                    print("Invalid response")
                    return
                }
                
                // Parse data
                SVProgressHUD.dismiss()
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(DimensionDataModel.self, from: data)
                        
                        let responseString = String(data: data, encoding: .utf8) ?? ""
                        print("Dimension Response :: \(responseString)")

                        let isSuccess: Bool = res.success!
                        DispatchQueue.main.async {
                            if isSuccess {
                                self.dimensionLimitDetails = res.data ?? []
                                
                                let minWidth = self.dimensionLimitDetails[0].minWidth ?? 0
                                let maxWidth = self.dimensionLimitDetails[0].maxWidth ?? 0
                                let widthDifference = self.dimensionLimitDetails[0].widthInterval ?? 0
                                for width in stride(from: minWidth, through: maxWidth, by: widthDifference) {
                                    self.widthRangeArr.append(Double(width))
                                }
                                //print("Width Range : \(self.widthRangeArr)")
                                self.widthRangeCollectionVw.reloadData()
                                
                                
                                let minHeigth = self.dimensionLimitDetails[0].minHeight ?? 0
                                let maxHeigth = self.dimensionLimitDetails[0].maxHeight ?? 0
                                let heigthDifference = self.dimensionLimitDetails[0].heightInterval ?? 0
                                for width in stride(from: minHeigth, through: maxHeigth, by: heigthDifference) {
                                    self.heightRangeArr.append(Double(width))
                                }
                                //print("Height Range : \(self.heightRangeArr)")
                                self.heightRangeCollectionVw.reloadData()

                                self.dimensionHeightRangeLbl.text = "Height Range: \(minHeigth)-\(maxHeigth) inch"
                                self.dimensionWidthRangeLbl.text = "Width Range: \(minWidth)-\(maxWidth) inch"
                            }
                            else {
                                self.showAlert(title: "Alert", message: res.message ?? "")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    //New Dimension Button Action....
    @IBAction func onNewDimensionPopupCancelBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.dimensionSubPopupVw.isHidden = true
    }
    
    @IBAction func onNewDimensionMinusBtnTap(_ sender: UIButton) {
        self.totalQuantity = Int(self.quantityDimensionTxtField.text ?? "") ?? 0
        if self.totalQuantity == 1 {
            showAlert(title: "Alert", message: "Minimum quantity is 1.")
            self.totalQuantity = 1
        } else {
            self.totalQuantity = self.totalQuantity - 1
        }
        self.quantityDimensionTxtField.text = "\(self.totalQuantity)"
    }
    
    @IBAction func onNewDimensionPlusBtnTap(_ sender: UIButton) {
        self.totalQuantity = Int(self.quantityDimensionTxtField.text ?? "") ?? 0
        if self.totalQuantity == 200 {
            self.totalQuantity = 200
            showAlert(title: "Alert", message: "You reached max quantity.")
        } else {
            self.totalQuantity = self.totalQuantity + 1
        }
        self.quantityDimensionTxtField.text = "\(self.totalQuantity)"
    }
    
    @IBAction func onNewDimensionSaveBtnTap(_ sender: UIButton) {
        print("Added New Dimension Save Btn Tap...")
        let width = Double(self.widthDimentionTxtField.text ?? "") ?? 0.0
        let height = Double(self.heightDimentionTxtField.text ?? "") ?? 0.0
        self.totalQuantity = Int(self.quantityDimensionTxtField.text ?? "") ?? 0
        let quantity = self.totalQuantity
        
        if width == 0 {
            showAlert(title: "Alert!", message: "Please enter width.")
        }
        else if height == 0 {
            showAlert(title: "Alert!", message: "Please enter height.")
        }
        else if quantity == 0 {
            showAlert(title: "Alert!", message: "Please enter Quantity.")
        }
        else if self.dimensionWidthErrorLbl.text != "" {
            showAlert(title: "Alert!", message: "Please enter valid width.")
        }
        else if self.dimensionHeightErrorLbl.text != "" {
            showAlert(title: "Alert!", message: "Please enter valid height.")
        }
        else {
//            let obj = DimensionDetails(width: width, height: height, quantity: quantity)
            let obj = DimensionDetails(width: "\(width)", height: "\(height)", quantity: quantity)
            
            if self.isDimensionEdit {
                self.dimensionDetailsArr[self.isDimensionEditIndex] = obj
            } else {
                self.dimensionDetailsArr.append(obj)
            }
            self.dimensionCollectionVw.reloadData()
            self.updateSrollVwHeight(window: self.windowProductsArr.count, insectMesh: self.addInsectMeshArr.count, glass: self.glassArr.count, color: self.colorsArr.count, anchourage: self.anchorageArr.count, dimension: self.dimensionDetailsArr.count)
            
            self.nextBtnVw.isHidden = true
            self.proceedCartBtnVw.isHidden = false
            self.mainPopupVw.isHidden = true
            self.dimensionSubPopupVw.isHidden = true
        }
    }
    
    //Save Swing Option Button...
    @IBAction func onSwingOptionCloseBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.swingOptionSubPopupVw.isHidden = true
    }
    
    @IBAction func onSelectSwingOptionSaveBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.swingOptionSubPopupVw.isHidden = true
        
        if self.windowHandSwing == "Left" {
            self.windowProductsArr[self.windowTypeIndex].isLeftSelected = true
            self.windowProductsArr[self.windowTypeIndex].isRightSelected = false
        }
        else if self.windowHandSwing == "Right" {
            self.windowProductsArr[self.windowTypeIndex].isLeftSelected = false
            self.windowProductsArr[self.windowTypeIndex].isRightSelected = true
        } else {
            self.windowProductsArr[self.windowTypeIndex].isLeftSelected = false
            self.windowProductsArr[self.windowTypeIndex].isRightSelected = false
        }
        self.windowCollectionVw.reloadData()
    }
    
    @IBAction func onLeftSwingBtnTap(_ sender: UIButton) {
        self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioSelect")
        self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
        self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
        self.windowHandSwing = "Left"
        self.swingSaveBtnEnable()
    }
    
    @IBAction func onRightSwingBtnTap(_ sender: UIButton) {
        self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
        self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioSelect")
        self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
        self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        self.windowHandSwing = "Right"
        self.swingSaveBtnEnable()
    }
    
    func swingSaveBtnEnable() {
        self.selectSwingSaveBtn.isUserInteractionEnabled = true
        self.selectSwingSaveBtn.backgroundColor = UIColor(hex: "#008BBF", alpha: 1.0)
    }
    
    func swingSaveBtnDisable() {
        self.selectSwingSaveBtn.isUserInteractionEnabled = false
        self.selectSwingSaveBtn.backgroundColor = UIColor(hex: "#BDBDBD", alpha: 1.0)
    }
    
    //Glass Info Option Button...
    @IBAction func onGlassOptionCloseBtnTap(_ sender: UIButton) {
        self.mainPopupVw.isHidden = true
        self.glassOptionInfoSubPopupVw.isHidden = true
    }
    
    
    //Dimension Range Button...
    @IBAction func onWidthRangeBtnTap(_ sender: UIButton) {
        self.heightRangeBaseVw.isHidden = true
        if self.widthRangeArr.count == 0 {
            self.showAlert(title: "Alert", message: "Width Dimension Data Not Found")
        } else {
            if widthRangeBaseVw.isHidden {
                self.widthRangeBaseVw.isHidden = false
            } else {
                self.widthRangeBaseVw.isHidden = true
            }
        }
    }
    
    @IBAction func onHeightRangeBtnTap(_ sender: UIButton) {
        self.widthRangeBaseVw.isHidden = true
        if self.heightRangeArr.count == 0 {
            self.showAlert(title: "Alert", message: "Height Dimension Data Not Found")
        } else {
            if heightRangeBaseVw.isHidden {
                self.heightRangeBaseVw.isHidden = false
            } else {
                self.heightRangeBaseVw.isHidden = true
            }
        }
    }
}


//MARK: CollectionView Delegate Method...
extension CustomizationVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.windowCollectionVw:
            return self.windowProductsArr.count
            
        case self.addInsectMeshCollectionVw:
            return self.addInsectMeshArr.count
            
        case glassCollectionVw:
            return self.glassArr.count
            
        case colorCollectionVw:
            return self.colorsArr.count
            
        case anchorageCollectionVW:
            return self.anchorageArr.count
            
        case dimensionCollectionVw:
            if self.dimensionDetailsArr.count == 0 {
                return 1
            } else {
                if self.isEdit {
                    return self.dimensionDetailsArr.count
                } else {
                    return self.dimensionDetailsArr.count + 1
                }
            }
            
        case widthRangeCollectionVw:
            return self.widthRangeArr.count
            
        case heightRangeCollectionVw:
            return self.heightRangeArr.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.windowCollectionVw:
            let cell = windowCollectionVw.dequeueReusableCell(withReuseIdentifier: CustomizeWindowCVC.identifier, for: indexPath) as! CustomizeWindowCVC
            
            let windowdetail = self.windowProductsArr[indexPath.row]
            //cell.imgVw.moa.url = windowdetail.productImage
            cell.imgVwWidth.constant = CGFloat(Constants.Is_iPad ? 55.0 : 40.0)
            cell.titleLbl.text = windowdetail.productName
            cell.priceLbl.text = "+$\(windowdetail.price ?? "")"
            cell.infoBtnWidth.constant = 0.0
            cell.priceVw.isHidden = true
            
            //-->Load Product Images...
            let baseURL = self.customizeResult?.baseImageURL ?? ""
            let categoryID = windowdetail.categoryID ?? 0
            let productID = windowdetail.id ?? 0
            let productUrl = "\(baseURL)\(categoryID)/\(productID)/image.png"
            print(productUrl)
            cell.imgVw.image = nil
            cell.imgVw.moa.onSuccess = { image in
                print("window Image successfully loaded!")
                SVProgressHUD.dismiss()
                return image
            }
            cell.imgVw.moa.onError = { error, response in
                print("Failed to load window image: \(String(describing: error?.localizedDescription))")
                SVProgressHUD.dismiss()
                self.baseWindowImgVw.image = UIImage(named: "")
            }
            cell.imgVw.moa.url = productUrl
            
            if self.windowSelectedIndex == indexPath.row {
                cell.baseView.layer.borderWidth = 0.8
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
                
                //swing option enable
                cell.SwingSideView.isUserInteractionEnabled = true
                
            } else {
                cell.baseView.layer.borderWidth = 0.0
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
                
                //swing option disable
                cell.SwingSideView.isUserInteractionEnabled = false
            }
            
            cell.leftHandSwingBtn.tag = indexPath.row
            cell.leftHandSwingBtn.addTarget(self, action: #selector(tapLeftRightHandSwingBtn(sender:)), for: .touchUpInside)
            cell.rightHandSwingBtn.tag = indexPath.row
            cell.rightHandSwingBtn.addTarget(self, action: #selector(tapLeftRightHandSwingBtn(sender:)), for: .touchUpInside)
            
            cell.detailsVw.layer.borderWidth = 0.0
            cell.SwingSideViewHeight.constant = 0.0
            cell.glassOptionVwHeight.constant = 0.0
            cell.glassOptionBgVw.isHidden = true
            
            if windowdetail.isSwing == 1 { // Swing option visible...
                cell.SwingSideViewHeight.constant = CGFloat(Constants.Is_iPad ? 60.0 : 40.0)
                if windowdetail.isLeftSelected ?? false {
                    cell.leftSwingBaseVw.backgroundColor = UIColor.init(hex: "008BBF", alpha: 1.0)
                    cell.leftSwingLbl.textColor = UIColor.white
                    cell.rightSwingBaseVw.backgroundColor = UIColor.init(hex: "F3F3F6", alpha: 1.0)
                    cell.rightSwingLbl.textColor = UIColor.init(hex: "919394", alpha: 1.0)
                }
                else if windowdetail.isRightSelected ?? false {
                    cell.leftSwingBaseVw.backgroundColor = UIColor.init(hex: "F3F3F6", alpha: 1.0)
                    cell.leftSwingLbl.textColor = UIColor.init(hex: "919394", alpha: 1.0)
                    cell.rightSwingBaseVw.backgroundColor = UIColor.init(hex: "008BBF", alpha: 1.0)
                    cell.rightSwingLbl.textColor = UIColor.white
                }
                else {
                    cell.leftSwingBaseVw.backgroundColor = UIColor.init(hex: "F3F3F6", alpha: 1.0)
                    cell.leftSwingLbl.textColor = UIColor.init(hex: "919394", alpha: 1.0)
                    cell.rightSwingBaseVw.backgroundColor = UIColor.init(hex: "F3F3F6", alpha: 1.0)
                    cell.rightSwingLbl.textColor = UIColor.init(hex: "919394", alpha: 1.0)
                }
            }
            else { // i button show...
                cell.infoBtnWidth.constant = CGFloat(Constants.Is_iPad ? 55.0 : 30.0)
                cell.infoBtn.tag = indexPath.row
                cell.infoBtn.addTarget(self, action: #selector(tapWindowInfoBtn(sender:)), for: .touchUpInside)
            }

            return cell
            
        case self.addInsectMeshCollectionVw:
            let cell = addInsectMeshCollectionVw.dequeueReusableCell(withReuseIdentifier: CustomizeWindowCVC.identifier, for: indexPath) as! CustomizeWindowCVC
            
            cell.imgVw.image = UIImage(named: "ic_insertMesh")
            cell.imgVwWidth.constant = CGFloat(Constants.Is_iPad ? 55.0 : 40.0)
            cell.titleLbl.text = self.addInsectMeshArr[indexPath.row]
            cell.priceLbl.text = "+$0.5"
            cell.infoBtnWidth.constant = CGFloat(Constants.Is_iPad ? 55.0 : 30.0)
            
            cell.priceVw.isHidden = true
            cell.detailsVw.layer.borderWidth = 0.0
            cell.SwingSideViewHeight.constant = 0.0
            cell.glassOptionVwHeight.constant = 0.0
            cell.glassOptionBgVw.isHidden = true

            if self.isEdit {
                print("Come From Edit.")
                if self.isSelectedInsectMesh {
                    cell.baseView.layer.borderWidth = 0.8
                    cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
                } else {
                    cell.baseView.layer.borderWidth = 0.0
                    cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
                }
            } else {
                if self.selectedAddInsectMeshIndex.contains(indexPath.row) {
                    cell.baseView.layer.borderWidth = 0.8
                    cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
                } else {
                    cell.baseView.layer.borderWidth = 0.0
                    cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
                }
            }

            cell.infoBtn.tag = indexPath.row
            cell.infoBtn.addTarget(self, action: #selector(tapInsectMeshInfoBtn(sender:)), for: .touchUpInside)
            
            return cell
            
        case self.glassCollectionVw:
            let cell = glassCollectionVw.dequeueReusableCell(withReuseIdentifier: CustomizeWindowCVC.identifier, for: indexPath) as! CustomizeWindowCVC
            
            let glassDetails = self.glassArr[indexPath.row]
            //cell.imgVw.moa.url = glassDetails.image
            cell.imgVw.image = UIImage(named: self.glassthumbImgArr[indexPath.row])
            cell.imgVwWidth.constant = 40.0  // thumbimage show = 40.0
            cell.titleLbl.text = glassDetails.name
            cell.priceLbl.text = "+$\(glassDetails.price ?? "")"
            cell.infoBtnWidth.constant = CGFloat(Constants.Is_iPad ? 45.0 : 30.0)
            
//            //-->Load Glass Images...
//            let baseURL = self.customizeResult?.baseImageURL ?? ""
//            let glassId = glassDetails.id ?? 0
//            let productUrl = "\(baseURL)\(self.category_id ?? 0)/\(self.product_id ?? 0)/\(glassId)/image.png"
//            print(productUrl)
//            cell.imgVw.image = nil
//            cell.imgVw.moa.onSuccess = { image in
//                print("glass Image successfully loaded!")
//                SVProgressHUD.dismiss()
//                return image
//            }
//            cell.imgVw.moa.onError = { error, response in
//                print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
//                SVProgressHUD.dismiss()
//                self.baseWindowImgVw.image = UIImage(named: "")
//            }
//            cell.imgVw.moa.url = productUrl
            
//            let displayPrice = glassDetails.displayPrice ?? 0
//            if displayPrice == 0 { //Price Not Display...
//                cell.priceVw.isHidden = true
//            } else { //Price Display...
//                cell.priceVw.isHidden = false
//            }
            cell.priceVw.isHidden = true
            cell.baseView.layer.borderWidth = 0.0
            cell.SwingSideViewHeight.constant = 0.0
            cell.newGlassSelection = self.glassAlreadySelected
            
            if self.glassSelectedIndex == indexPath.row {
                cell.detailsVw.layer.borderWidth = 0.8
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
                cell.glassOptionBgVw.isHidden = false
                
                //Glass Option View Height.....
                var glassOptionHeight = 0.0
                let font = UIFont(name: "Poppins-Regular", size: 16.0) ?? UIFont.systemFont(ofSize: 16)
                
                let subOptionList = glassDetails.options ?? []
                for optionObj in subOptionList {
                    let optionName = optionObj.name ?? ""
                    let lblHeight = self.heightForView(text: optionName, font: font, width: self.glassCollectionVw.frame.width - 116.0)
                    let cellHeight = lblHeight + 20.0
                    if cellHeight < 45.0 {
                        glassOptionHeight = glassOptionHeight + 50.0
                    } else {
                        glassOptionHeight = glassOptionHeight + cellHeight
                    }
                }
                cell.glassOptionVwHeight.constant = glassOptionHeight
                
                //cell.optionlist = self.glassOptionArr[indexPath.row]
                let subOptions = glassDetails.options ?? []
                cell.subOptions = subOptions
                
                if cell.radioImgVw.image == UIImage(named: "ic_radioSelect") {
                    //Collection not reload....
                } else {
                    cell.selectedOptionIndex = []
                    cell.selectedSubOption = []
                    cell.optionCollectionVw.reloadData()
                }
                
                if glassDetails.selected == true {
                    //==> save selected suboption in userdefaults.....
                    if let encodedSubOptions = try? JSONEncoder().encode(subOptions) {
                        UserDefaults.standard.set(encodedSubOptions, forKey: "subOptions")
                    } else {
                        print("glass sub option not found.")
                    }
                }
                else {
                    print("not selected from edit")
                }
            } else {
                cell.detailsVw.layer.borderWidth = 0.0
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
                cell.glassOptionBgVw.isHidden = true
                cell.glassOptionVwHeight.constant = 0.0
            }
            cell.initUI()
            cell.optionCollectionVw.reloadData()
            
            cell.infoBtn.tag = indexPath.row
            cell.infoBtn.addTarget(self, action: #selector(tapGlassInfoBtn(sender:)), for: .touchUpInside)
            
            return cell
            
        case self.colorCollectionVw:
            let cell = colorCollectionVw.dequeueReusableCell(withReuseIdentifier: CustomizeWindowCVC.identifier, for: indexPath) as! CustomizeWindowCVC
            
            let colorDetails = self.colorsArr[indexPath.row]
            //cell.imgVw.moa.url = colorDetails.image
            cell.imgVw.backgroundColor = UIColor(hex: colorDetails.code ?? "", alpha: 1.0)
            cell.imgVwWidth.constant = CGFloat(Constants.Is_iPad ? 100.0 : 70.0) //ImageView width...
            cell.titleLbl.text = colorDetails.name
            cell.priceLbl.text = "+$\(colorDetails.price ?? "")"
            cell.infoBtnWidth.constant = 0.0
            
            //-->Load Glass Images...
            let baseURL = self.customizeResult?.baseImageURL ?? ""
            let colorId = colorDetails.id ?? 0
            let productUrl = "\(baseURL)\(self.category_id ?? 0)/\(self.product_id ?? 0)/\(self.glass_id ?? 0)/\(colorId)/image.png"
            print(productUrl)
            cell.imgVw.moa.onSuccess = { image in
                print("glass Image successfully loaded!")
                SVProgressHUD.dismiss()
                return image
            }
            cell.imgVw.moa.onError = { error, response in
                print("Failed to load glass image: \(String(describing: error?.localizedDescription))")
                SVProgressHUD.dismiss()
                self.baseWindowImgVw.image = UIImage(named: "")
            }
            //cell.imgVw.moa.url = productUrl
            
//            let displayPrice = colorDetails.displayPrice ?? 0
//            if displayPrice == 0 { //Price Not Display...
//                cell.priceVw.isHidden = true
//            } else { //Price Display...
//                cell.priceVw.isHidden = false
//            }
            cell.priceVw.isHidden = true
            cell.detailsVw.layer.borderWidth = 0.0
            cell.SwingSideViewHeight.constant = 0.0
            cell.glassOptionVwHeight.constant = 0.0
            cell.glassOptionBgVw.isHidden = true

            if self.colorSelectedIndex == indexPath.row {
                cell.baseView.layer.borderWidth = 0.8
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
            } else {
                cell.baseView.layer.borderWidth = 0.0
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
            }
            
            return cell
            
        case self.anchorageCollectionVW:
            let cell = anchorageCollectionVW.dequeueReusableCell(withReuseIdentifier: CustomizeWindowCVC.identifier, for: indexPath) as! CustomizeWindowCVC
            
            let anchorageDetails = self.anchorageArr[indexPath.row]
//            cell.imgVw.moa.url = anchorageDetails.image
//            cell.imgVwWidth.constant = 40.0
            cell.imgVwWidth.constant = 0.0
            cell.titleLbl.text = anchorageDetails.name
            cell.priceLbl.text = "+$\(anchorageDetails.price ?? "")"
            cell.infoBtnWidth.constant = CGFloat(Constants.Is_iPad ? 55.0 : 30.0)
            
//            let displayPrice = anchorageDetails.displayPrice ?? 0
//            if displayPrice == 0 { //Price Not Display...
//                cell.priceVw.isHidden = true
//            } else { //Price Display...
//                cell.priceVw.isHidden = false
//            }
            cell.priceVw.isHidden = true
            cell.detailsVw.layer.borderWidth = 0.0
            cell.SwingSideViewHeight.constant = 0.0
            cell.glassOptionVwHeight.constant = 0.0
            cell.glassOptionBgVw.isHidden = true

            if self.anchorageSelectedIndex == indexPath.row {
                cell.baseView.layer.borderWidth = 0.8
                cell.radioImgVw.image = UIImage(named: "ic_radioSelect")
            } else {
                cell.baseView.layer.borderWidth = 0.0
                cell.radioImgVw.image = UIImage(named: "ic_radioUnselect")
            }

            cell.infoBtn.tag = indexPath.row
            cell.infoBtn.addTarget(self, action: #selector(tapAnchorageInfoBtn(sender:)), for: .touchUpInside)

            return cell

        case self.dimensionCollectionVw:
            let cell = dimensionCollectionVw.dequeueReusableCell(withReuseIdentifier: DimensionCustomizeCVC.identifier, for: indexPath) as! DimensionCustomizeCVC
            
            if self.dimensionDetailsArr.count == 0 {
                cell.btnMainVw.isHidden = false
                cell.detailsVw.isHidden = true
                
                cell.addNewBtn.tag = indexPath.row
                cell.addNewBtn.addTarget(self, action: #selector(tapAddNewBtn(sender:)), for: .touchUpInside)
            } else {
                if self.isEdit {
                    cell.btnMainVw.isHidden = true
                    cell.detailsVw.isHidden = false
                    
                    let obj = self.dimensionDetailsArr[indexPath.row]
                    cell.widthLbl.text = "\(obj.width)"
                    cell.heightLbl.text = "\(obj.height)"
                    cell.quantityLbl.text = "\(obj.quantity)"
                    
                    cell.deleteBtn.tag = indexPath.row
                    cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn(sender:)), for: .touchUpInside)
                    cell.editBtn.tag = indexPath.row
                    cell.editBtn.addTarget(self, action: #selector(tapEditBtn(sender:)), for: .touchUpInside)
                }
                else {
                    if indexPath.row == self.dimensionDetailsArr.count {
                        cell.btnMainVw.isHidden = false
                        cell.detailsVw.isHidden = true
                        
                        cell.addNewBtn.tag = indexPath.row
                        cell.addNewBtn.addTarget(self, action: #selector(tapAddNewBtn(sender:)), for: .touchUpInside)
                    }
                    else {
                        cell.btnMainVw.isHidden = true
                        cell.detailsVw.isHidden = false
                        
                        let obj = self.dimensionDetailsArr[indexPath.row]
                        cell.widthLbl.text = "\(obj.width)"
                        cell.heightLbl.text = "\(obj.height)"
                        cell.quantityLbl.text = "\(obj.quantity)"
                        
                        cell.deleteBtn.tag = indexPath.row
                        cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn(sender:)), for: .touchUpInside)
                        cell.editBtn.tag = indexPath.row
                        cell.editBtn.addTarget(self, action: #selector(tapEditBtn(sender:)), for: .touchUpInside)
                    }
                }
            }
            
            return cell

        case widthRangeCollectionVw:
            let cell = widthRangeCollectionVw.dequeueReusableCell(withReuseIdentifier: DimensionRangeCVC.identifier, for: indexPath) as! DimensionRangeCVC
            cell.titleLbl.text = "\(self.widthRangeArr[indexPath.row])"
            return cell
            
        case heightRangeCollectionVw:
            let cell = heightRangeCollectionVw.dequeueReusableCell(withReuseIdentifier: DimensionRangeCVC.identifier, for: indexPath) as! DimensionRangeCVC
            cell.titleLbl.text = "\(self.heightRangeArr[indexPath.row])"
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 22.0 : 16.0) ?? UIFont.systemFont(ofSize: 16)
        switch collectionView {
        case windowCollectionVw:
//            return CGSize(width: self.windowCollectionVw.frame.size.width, height: 78.0)
            var totalWindowVwHeight = 0.0
            let windowdetail = self.windowProductsArr[indexPath.row]
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
            if windowdetail.isSwing == 1 { // Swing option visible...
                let windowName = windowdetail.productName ?? ""
                let width = leadingTraillingMargin - CGFloat(Constants.Is_iPad ? 45.0 : 30.0) //info button hide...
                let lblHeight = self.heightForView(text: windowName, font: font, width: self.view.frame.width - width)
                var cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0)
                cellHeight = cellHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0)
                
                let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                if cellHeight < imgVwHeigthWithMargin {
                    totalWindowVwHeight = CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
                } else {
                    totalWindowVwHeight = totalWindowVwHeight + cellHeight + baseVwTopBottomMargin
                }
                let swingVwHeight = CGFloat(Constants.Is_iPad ? 60.0 : 40.0)
                totalWindowVwHeight = totalWindowVwHeight + swingVwHeight
            }
            else {
                let windowName = windowdetail.productName ?? ""
                let lblHeight = self.heightForView(text: windowName, font: font, width: self.view.frame.width - leadingTraillingMargin)
                var cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0)
                cellHeight = cellHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0)
                
                let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
                if cellHeight < imgVwHeigthWithMargin {
                    totalWindowVwHeight = CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
                } else {
                    totalWindowVwHeight = totalWindowVwHeight + cellHeight + baseVwTopBottomMargin
                }
            }
                        
            return CGSize(width: self.windowCollectionVw.frame.size.width, height: totalWindowVwHeight)
            
        case addInsectMeshCollectionVw:
            var totalAddInsectMeshVwHeight = 0.0
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let addInsectMeshName = self.addInsectMeshArr[indexPath.row]
            let lblHeight = self.heightForView(text: addInsectMeshName, font: font, width: self.view.frame.width - leadingTraillingMargin) //180 = i Btn show & +40 thumb image show...
            let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0) //46 = price lbl show & top bottom margin...
            
            let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
            if cellHeight < imgVwHeigthWithMargin {
                totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
            } else {
                //let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 25.0)
                totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight + cellHeight + baseVwTopBottomMargin //16 = baseview top bottom margin...
            }
            totalAddInsectMeshVwHeight = totalAddInsectMeshVwHeight - 25.0 //-25 is price view height
            return CGSize(width: self.addInsectMeshCollectionVw.frame.size.width, height: totalAddInsectMeshVwHeight)
            
        case glassCollectionVw:
            var totalGlassVwHeight = 0.0
            var glassOptionHeight = 0.0
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let thumbImgWidth = CGFloat(Constants.Is_iPad ? 55.0 : 40.0)
            let glassName = self.glassArr[indexPath.row].name ?? ""
            let lblHeight = self.heightForView(text: glassName, font: font, width: self.view.frame.width - leadingTraillingMargin + thumbImgWidth)
            let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0)
            
            let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
            if cellHeight < imgVwHeigthWithMargin {
                totalGlassVwHeight = CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
            } else {
                let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                totalGlassVwHeight = totalGlassVwHeight + cellHeight + baseVwTopBottomMargin
            }
            
//            let displayPrice = self.glassArr[indexPath.row].displayPrice ?? 0
//            if displayPrice == 0 { //Price Not Display...
//                totalGlassVwHeight = totalGlassVwHeight - 25.0 //-25 is price view height
//            }
            totalGlassVwHeight = totalGlassVwHeight - CGFloat(Constants.Is_iPad ? 45.0 : 25.0) //-25 is price view height
            
            //Glass Option View Height.....
            if self.glassSelectedIndex == indexPath.row {
//                totalGlassVwHeight = totalGlassVwHeight + 50.0 //50 is option view height
                
                let subOptionList = self.glassArr[indexPath.row].options ?? []
                for optionObj in subOptionList {
                    let optionName = optionObj.name ?? ""
                    let lblHeight = self.heightForView(text: optionName, font: font, width: self.glassCollectionVw.frame.width - 116.0)
                    let cellHeight = lblHeight + 20.0
                    if cellHeight < 45.0 {
                        glassOptionHeight = glassOptionHeight + 50.0
                    } else {
                        glassOptionHeight = glassOptionHeight + cellHeight
                    }
                }
            }
            totalGlassVwHeight = totalGlassVwHeight + glassOptionHeight
            return CGSize(width: self.glassCollectionVw.frame.size.width, height: totalGlassVwHeight)

        case colorCollectionVw:
            var totalColorVwHeight = 0.0
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let colorName = self.colorsArr[indexPath.row].name ?? ""
            let lblHeight = self.heightForView(text: colorName, font: font, width: self.view.frame.width - leadingTraillingMargin)
            let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 30.0 : 21.0)
            
            let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
            if cellHeight < imgVwHeigthWithMargin {
                totalColorVwHeight = totalColorVwHeight + CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
            } else {
                let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                totalColorVwHeight = totalColorVwHeight + cellHeight + baseVwTopBottomMargin
            }
            return CGSize(width: self.colorCollectionVw.frame.size.width, height: totalColorVwHeight)

        case anchorageCollectionVW:
            var totalAnchorageVwHeight = 0.0
            let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 300.0 : 180.0)
            let anchorageName = self.anchorageArr[indexPath.row].name ?? ""
            let lblHeight = self.heightForView(text: anchorageName, font: font, width: self.view.frame.width - leadingTraillingMargin) //40.0 is thumb image hidden...
            let cellHeight = lblHeight + CGFloat(Constants.Is_iPad ? 85.0 : 46.0)
            
            let imgVwHeigthWithMargin = Constants.Is_iPad ? 99.0 : 62.0
            if cellHeight < imgVwHeigthWithMargin {
                totalAnchorageVwHeight = CGFloat(Constants.Is_iPad ? 130.0 : 78.0)
            } else {
                let baseVwTopBottomMargin = CGFloat(Constants.Is_iPad ? 30.0 : 16.0)
                totalAnchorageVwHeight = totalAnchorageVwHeight + cellHeight + baseVwTopBottomMargin
            }
            
//            let displayPrice = self.anchorageArr[indexPath.row].displayPrice ?? 0
//            if displayPrice == 0 { //Price Not Display...
//                totalAnchorageVwHeight = totalAnchorageVwHeight - 25.0 //-25 is price view height
//            }
            totalAnchorageVwHeight = totalAnchorageVwHeight - 25.0 //-25 is price view height
            return CGSize(width: self.anchorageCollectionVW.frame.size.width, height: totalAnchorageVwHeight)
            
        case dimensionCollectionVw:
            let addDimensionCellHeight = CGFloat(Constants.Is_iPad ? 80.0 : 55.0)
            if self.dimensionDetailsArr.count == 0 {
                return CGSize(width: self.dimensionCollectionVw.frame.size.width, height: addDimensionCellHeight)
            } else {
                if indexPath.row == self.dimensionDetailsArr.count {
                    return CGSize(width: self.dimensionCollectionVw.frame.size.width, height: addDimensionCellHeight)
                } else {
                    let dimensionCellHeight = CGFloat(Constants.Is_iPad ? 125.0 : 95.0)
                    return CGSize(width: self.dimensionCollectionVw.frame.size.width, height: dimensionCellHeight)
                }
            }

        case widthRangeCollectionVw:
            return CGSize(width: self.widthRangeCollectionVw.frame.size.width, height: 40.0)
            
        case heightRangeCollectionVw:
            return CGSize(width: self.heightRangeCollectionVw.frame.size.width, height: 40.0)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var isGlassSelection = false
        
        switch collectionView {
        case windowCollectionVw:
            self.baseWindowImgVw.isHidden = false
            self.showGlassImgVw.isHidden = false
            self.showObsureGlassOptionImgVw.isHidden = false
            self.showMuntinsGlassOptionImgVw.isHidden = false
            self.showColorImgVw.isHidden = false
            self.showSubImageVw.isHidden = true
            if self.isEdit {
                showAlert(title: "Attention!", message: "Base Window cannot be changed")
            } else {
                self.windowSelectedIndex = indexPath.row
                self.product_id = self.windowProductsArr[self.windowSelectedIndex].id ?? 0
                self.windowCollectionVw.reloadData()
                                
                self.windowProductsArr[self.windowTypeIndex].isLeftSelected = false
                self.windowProductsArr[self.windowTypeIndex].isRightSelected = false
                
                let window = self.windowProductsArr[indexPath.row]
                if window.isInsectMeshVisible ?? false {
                    self.isAddInsectMeshVisible = true
                } else {
                    self.isAddInsectMeshVisible = false
                }
                self.updateSrollVwHeight(window: self.windowProductsArr.count, insectMesh: self.addInsectMeshArr.count, glass: self.glassArr.count, color: self.colorsArr.count, anchourage: self.anchorageArr.count, dimension: self.dimensionDetailsArr.count)
                
                //--> Set Slider.....
                DispatchQueue.main.async {
                    let selectedProductImages = self.windowProductsArr[self.windowSelectedIndex].images ?? []
                    if selectedProductImages.count > 1 {
                        self.setupSlider(arrayCount: selectedProductImages.count)
                        self.leftrightButtonVw.isHidden = false
                    } else {
                        self.leftrightButtonVw.isHidden = true
                    }
                }
            }
            
        case self.addInsectMeshCollectionVw:
            self.addInsectMeshCollectionVw.reloadData()
            if let index = self.selectedAddInsectMeshIndex.firstIndex(of: indexPath.row) {
                print("removed.")
                self.addedInsectMesh = false
                self.selectedAddInsectMeshIndex.remove(at: index)
                self.isSelectedInsectMesh = false
            } else {
                print("added.")
                self.addedInsectMesh = true
                self.selectedAddInsectMeshIndex.append(indexPath.row)
                self.isSelectedInsectMesh = true
            }
            collectionView.reloadItems(at: [indexPath])
        
        case glassCollectionVw:
            isGlassSelection = true
            if self.glassSelectedIndex == indexPath.row {
                self.glassAlreadySelected = true
            } else {
                self.glassAlreadySelected = false
            }
            
            self.glassSelectedIndex = indexPath.row
            self.glass_id = self.glassArr[self.glassSelectedIndex].id ?? 0
            
            self.updateSrollVwHeight(window: self.windowProductsArr.count, insectMesh: self.addInsectMeshArr.count, glass: self.glassArr.count, color: self.colorsArr.count, anchourage: self.anchorageArr.count, dimension: self.dimensionDetailsArr.count)
            
        case colorCollectionVw:
            self.colorSelectedIndex = indexPath.row
            self.colorCollectionVw.reloadData()
            self.color_id = self.colorsArr[self.colorSelectedIndex].id ?? 0
            
        case anchorageCollectionVW:
            self.anchorageSelectedIndex = indexPath.row
            self.anchorageCollectionVW.reloadData()
            self.anchorage_id = self.anchorageArr[self.anchorageSelectedIndex].id ?? 0
            //self.showAnchorageImgVw.moa.url = self.anchorageArr[self.anchorageSelectedIndex].image
            
        case dimensionCollectionVw:
            break
            
        case widthRangeCollectionVw:
            self.widthRangeBaseVw.isHidden = true
            self.widthDimentionTxtField.text = "\(self.widthRangeArr[indexPath.row])"
            
        case heightRangeCollectionVw:
            self.heightRangeBaseVw.isHidden = true
            self.heightDimentionTxtField.text = "\(self.heightRangeArr[indexPath.row])"

        default:
            break
        }
        
        //Update show image as per selection...
        let baseURL = self.customizeResult?.baseImageURL ?? ""
        let categoryID = self.windowProductsArr[self.windowSelectedIndex].categoryID ?? 0
        self.imageUpdate(baseURL: baseURL, categoryId: categoryID, productId: self.product_id, glassId: self.glass_id, glassOption: self.glassSubOptionsName, colorId: self.color_id, glassAlreadySelected: self.glassAlreadySelected, isGlassSelection: isGlassSelection)
    }
    
    
    
    @objc func tapAddNewBtn(sender: UIButton) {
        print("Tap Add New Dimension Btn")
//        self.fetchDimensionApiCall()
        self.mainPopupVw.isHidden = false
        self.dimensionSubPopupVw.isHidden = false
        self.isDimensionEdit = false
        
        self.widthDimentionTxtField.text = ""
        self.heightDimentionTxtField.text = ""
        self.quantityDimensionTxtField.text = "\(self.totalQuantity)"
        
        self.widthRangeBaseVw.isHidden = true
        self.heightRangeBaseVw.isHidden = true
        
        let selectedWindow = self.windowProductsArr[self.windowSelectedIndex]
        self.dimensionHeightRangeLbl.text = "Height Range: \(selectedWindow.minHeight ?? "0") - \(selectedWindow.maxHeight ?? "0") inch"
        self.dimensionWidthRangeLbl.text = "Width Range: \(selectedWindow.minWidth ?? "0") - \(selectedWindow.maxWidth ?? "0") inch"
        self.dimensionWidthErrorLbl.text = ""
        self.dimensionHeightErrorLbl.text = ""
    }

    @objc func tapDeleteBtn(sender: UIButton) {
        print("Tap Delete Dimension Btn at : \(sender.tag)")
        self.dimensionDetailsArr.remove(at: sender.tag)
        self.updateSrollVwHeight(window: self.windowProductsArr.count, insectMesh: self.addInsectMeshArr.count, glass: self.glassArr.count, color: self.colorsArr.count, anchourage: self.anchorageArr.count, dimension: self.dimensionDetailsArr.count)
        self.dimensionCollectionVw.reloadData()
        
        if self.dimensionDetailsArr.count > 0 {
            self.nextBtnVw.isHidden = true
            self.proceedCartBtnVw.isHidden = false
        } else {
            self.nextBtnVw.isHidden = false
            self.proceedCartBtnVw.isHidden = true
        }
    }
    
    @objc func tapEditBtn(sender: UIButton) {
        print("Tap Edit Dimension Btn at : \(sender.tag)")
        self.mainPopupVw.isHidden = false
        self.dimensionSubPopupVw.isHidden = false
        self.isDimensionEdit = true
        self.isDimensionEditIndex = sender.tag
        
        self.widthDimentionTxtField.text = "\(self.dimensionDetailsArr[sender.tag].width)"
        self.heightDimentionTxtField.text = "\(self.dimensionDetailsArr[sender.tag].height)"
        self.totalQuantity = self.dimensionDetailsArr[sender.tag].quantity
        self.quantityDimensionTxtField.text = "\(self.totalQuantity)"
        
        self.widthRangeBaseVw.isHidden = true
        self.heightRangeBaseVw.isHidden = true
        
        let selectedWindow = self.windowProductsArr[self.windowSelectedIndex]
        self.dimensionHeightRangeLbl.text = "Height Range: \(selectedWindow.minHeight ?? "0") - \(selectedWindow.maxHeight ?? "0") inch"
        self.dimensionWidthRangeLbl.text = "Width Range: \(selectedWindow.minWidth ?? "0") - \(selectedWindow.maxWidth ?? "0") inch"
        self.dimensionWidthErrorLbl.text = ""
        self.dimensionHeightErrorLbl.text = ""
    }
    
    @objc func tapWindowInfoBtn(sender: UIButton) {
        print("Tap Window Info Btn at : \(sender.tag)")
        self.mainPopupVw.isHidden = false
        self.windowInfoSubPopupVw.isHidden = false
        
        let windowdetail = self.windowProductsArr[sender.tag]
        let windowName = windowdetail.productName ?? ""
//        self.windowInfoPopupImgVw.image = UIImage(named: "ic_double")
        self.windowInfoPopupTitleLbl.text = windowName
        
        let instruction = windowdetail.instruction ?? ""
        self.windowInfoPopupLbl.text = instruction
        
        self.windowInfoPopupImgVw.image = UIImage(named: "")
        let instructionImageURL = windowdetail.instructionImage ?? ""
        self.windowInfoPopupImgVw.moa.url = instructionImageURL
        
        var imageHeight = 0.0
        var lblHeight = 0.0
        let font = UIFont(name: "Poppins-Medium", size: Constants.Is_iPad ? 22.0 : 14.0) ?? UIFont.systemFont(ofSize: 14)
        
        if windowName.elementsEqual("Single Fixed Window") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "") //Default Image
            imageHeight = 0.0
//            self.windowInfoPopupLbl.text = "A non-operable window designed for unobstructed views and maximum natural light, ideal for enhancing aesthetics and energy efficiency without ventilation."
            //lblHeight = 25.0
        }
        else if windowName.elementsEqual("Double Casement Operable") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "double casement")
            imageHeight = Constants.Is_iPad ? 220.0 : 150.0
//            self.windowInfoPopupLbl.text = "Two side-hinged windows that open outward, providing superior airflow and flexibility for large openings, while maintaining ease of operation and energy efficiency."
            
            //lblHeight = 0.0
        }
        else if windowName.elementsEqual("Single Awning Operable") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "single awning")
            imageHeight = Constants.Is_iPad ? 320.0 : 250.0
//            self.windowInfoPopupLbl.text = "Hinged at the top and opening outward, awning windows allow ventilation even during light rain while maintaining energy efficiency and weather protection."
            //lblHeight = 0.0
        }
        else if windowName.elementsEqual("Double Awning Operable") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "") //Default Image
            imageHeight = 0.0
//            self.windowInfoPopupLbl.text = "Two top-hinged windows that open outward, offering enhanced airflow and the ability to ventilate in light rain without compromising on protection or insulation."
            //lblHeight = 25.0
        }
        else if windowName.elementsEqual("Fixed under Awning Operable") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "fixed under awning")
            imageHeight = Constants.Is_iPad ? 400.0 : 300.0
//            self.windowInfoPopupLbl.text = "A vertical arrangement where the fixed window provides unobstructed views, while the awning window below offers ventilation with protection from rain."
            //lblHeight = 0.0
        }
        else if windowName.elementsEqual("Fixed over Awning Operable") {
//            self.windowInfoPopupImgVw.image = UIImage(named: "fixed over awning")
            imageHeight = Constants.Is_iPad ? 450.0 : 380.0
//            self.windowInfoPopupLbl.text = "A vertical arrangement where the fixed window provides unobstructed views, while the awning window above offers ventilation with protection from rain."
            //lblHeight = 0.0
        }
        
        //Description Lbl height.....
        let height = self.heightForView(text: self.windowInfoPopupLbl.text!, font: font, width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 360.0 : 80.0))
        lblHeight = height
    
        
        self.windowinfoPopupImgHeight.constant = imageHeight
        self.windowInfoPopupLblHeight.constant = lblHeight

        //Popup View Height.....
        var popupVwHeight = 0.0
        let lbl1Height = self.heightForView(text: self.windowInfoPopupTitleLbl.text ?? "", font: UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - CGFloat(Constants.Is_iPad ? 447.0 : 105.0))
        
        let vwHeight = self.view.frame.size.height - 100.0
        let finalHeight = lbl1Height + imageHeight + lblHeight + CGFloat(Constants.Is_iPad ? 102.0 : 56.0)
        if finalHeight > vwHeight {
            popupVwHeight = vwHeight
        } else {
            popupVwHeight = finalHeight
        }
        self.windowInfoPopupVwHeight.constant = popupVwHeight
    }

    @objc func tapInsectMeshInfoBtn(sender: UIButton) {
        print("Tap Insect Mesh Info Btn at : \(sender.tag)")
    }
    
    @objc func tapGlassInfoBtn(sender: UIButton) {
        print("Tap Glass Info Btn at : \(sender.tag)")
        self.mainPopupVw.isHidden = false
        self.glassInfoSubPopupVw.isHidden = false
        
        let glassDetail = self.glassArr[sender.tag]
        let glassName = glassDetail.name ?? ""
        self.glssInfoPopupTitleLbl.text = glassName
        
        let instruction = glassDetail.instruction ?? ""
        self.glassInfoPopupLbl.text = instruction
        
        self.glassInfoPopupImgVw.image = UIImage(named: "")
        let instructionImageURL = glassDetail.instructionImage ?? ""
        self.glassInfoPopupImgVw.moa.url = instructionImageURL
                
        //Popup View Height.....
        let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 350.0 : 68.0)
        var popupVwHeight = 0.0
        let lbl1Height = self.heightForView(text: self.glssInfoPopupTitleLbl.text ?? "", font: UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - leadingTraillingMargin)
        let lbl2Height = self.heightForView(text: self.glassInfoPopupLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 21.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
        
        let vwHeight = self.view.frame.size.height - 200.0
        let finalHeight = lbl1Height + lbl2Height + CGFloat(Constants.Is_iPad ? 385.0 : 240.0)
        if finalHeight > vwHeight {
            popupVwHeight = vwHeight
        } else {
            popupVwHeight = finalHeight
        }
        self.glassInfoPopupVwHeight.constant = popupVwHeight
    }

    @objc func tapAnchorageInfoBtn(sender: UIButton) {
        print("Tap Anchorage Info Btn at : \(sender.tag)")
        self.mainPopupVw.isHidden = false
        self.anchorageInfoSubPopupVw.isHidden = false
        
        let anchorageDetails = self.anchorageArr[sender.tag]
        let selectAnchorage = anchorageDetails.name ?? ""
        
        let instruction = anchorageDetails.instruction ?? ""
        self.anchorageInfoPopupLbl.text = instruction
        
        self.anchorageInfoPopupImgVw.image = UIImage(named: "")
        let instructionImageURL = anchorageDetails.instructionImage ?? ""
        self.anchorageInfoPopupImgVw.moa.url = instructionImageURL
        
        //print(selectAnchorage)
        if selectAnchorage.elementsEqual("Nail Fin") {
            self.anchorageInfoPopupTitleLbl.text = "Nail Fin"
        }
        else if selectAnchorage.elementsEqual("Integrated Anchor Channel") {
            self.anchorageInfoPopupTitleLbl.text = "Integrated Anchor Channel"
        }
        else if selectAnchorage.elementsEqual("Receptors") {
            self.anchorageInfoPopupTitleLbl.text = "Receptors"
        }
        
        //Popup View Height.....
        let leadingTraillingMargin = CGFloat(Constants.Is_iPad ? 350.0 : 68.0)
        var popupVwHeight = 0.0
        let lbl1Height = self.heightForView(text: self.anchorageInfoPopupTitleLbl.text ?? "", font: UIFont(name: "Poppins-SemiBold", size: Constants.Is_iPad ? 30.0 : 20.0) ?? UIFont.systemFont(ofSize: 20), width: self.view.frame.width - leadingTraillingMargin)
        let lbl2Height = self.heightForView(text: self.anchorageInfoPopupLbl.text ?? "", font: UIFont(name: "Poppins-Regular", size: Constants.Is_iPad ? 21.0 : 12.0) ?? UIFont.systemFont(ofSize: 12), width: self.view.frame.width - leadingTraillingMargin)
        
        let vwHeight = self.view.frame.size.height - 200.0
        let finalHeight = lbl1Height + lbl2Height + CGFloat(Constants.Is_iPad ? 395.0 : 245.0)
        if finalHeight > vwHeight {
            popupVwHeight = vwHeight
        } else {
            popupVwHeight = finalHeight
        }
        self.anchorageInfoPopupVwHeight.constant = popupVwHeight
    }
    
    @objc func tapLeftRightHandSwingBtn(sender: UIButton) {
        print("Tap Left Right Hand Swing...")
        self.windowTypeIndex = sender.tag
        
        self.mainPopupVw.isHidden = false
        self.swingOptionSubPopupVw.isHidden = false
        self.swingSaveBtnDisable()
        
        let windowSwingDetail = self.windowProductsArr[self.windowTypeIndex]
        if windowSwingDetail.isLeftSelected ?? false {
            self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioSelect")
            self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
            self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
            self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
        }
        else if windowSwingDetail.isRightSelected ?? false {
            self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
            self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioSelect")
            self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
            self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#008BBF", alpha: 1.0).cgColor
        }
        else {
            self.leftSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
            self.leftSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
            self.rightSwingPopupSubVw.layer.borderColor = UIColor(hex: "#D8E2EA", alpha: 1.0).cgColor
            self.rightSwingRadioImgVw.image = UIImage(named: "ic_radioUnselect")
        }
        
        
        let windowdetail = self.windowProductsArr[sender.tag]
        let windowName = windowdetail.productName ?? ""
        
        if windowName.elementsEqual("Single Casement Operable") {
            self.leftSwingPopupImgVw.image = UIImage(named: "single left")
            self.rightSwingPopupImgVw.image = UIImage(named: "single right")
        }
        else if windowName.elementsEqual("Casement Operable next to Fixed") {
            self.leftSwingPopupImgVw.image = UIImage(named: "casement oper left")
            self.rightSwingPopupImgVw.image = UIImage(named: "casement oper right")
        }
        else if windowName.elementsEqual("Awning Operable next to Fixed") {
            self.leftSwingPopupImgVw.image = UIImage(named: "awning oper left")
            self.rightSwingPopupImgVw.image = UIImage(named: "awning oper right")
        }
        else {
            self.leftSwingPopupImgVw.image = UIImage(named: "")
            self.rightSwingPopupImgVw.image = UIImage(named: "")
        }
    }
    
}

//MARK: Scroll View Delegate Method...
extension CustomizationVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print("Scroll view started scrolling")
        self.baseWindowImgVw.isHidden = false
        self.showGlassImgVw.isHidden = false
        self.showObsureGlassOptionImgVw.isHidden = false
        self.showMuntinsGlassOptionImgVw.isHidden = false
        self.showColorImgVw.isHidden = false
        self.showSubImageVw.isHidden = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("end scroll")
        
        let windowViewFrame = windowBaseVw.convert(windowBaseVw.bounds, to: scrollVw)
        let windowOffset = CGPoint(x: 0, y: windowViewFrame.origin.y)
        //print("Window :: \(windowOffset)")
        
        let addInsectMeshViewFrame = addInsectBaseVw.convert(addInsectBaseVw.bounds, to: scrollVw)
        let addInsectMeshOffset = CGPoint(x: 0, y: addInsectMeshViewFrame.origin.y)
        //print("Insect Mesh :: \(addInsectMeshOffset)")
        
        let glassViewFrame = glassBaseVw.convert(glassBaseVw.bounds, to: scrollVw)
        let glassOffset = CGPoint(x: 0, y: glassViewFrame.origin.y)
        //print("Glass :: \(glassOffset)")

        let colorViewFrame = colorBaseVw.convert(colorBaseVw.bounds, to: scrollVw)
        let colorOffset = CGPoint(x: 0, y: colorViewFrame.origin.y)
        //print("Color :: \(colorOffset)")

        let anchorageViewFrame = anchorageBaseVw.convert(anchorageBaseVw.bounds, to: scrollVw)
        let anchorageOffset = CGPoint(x: 0, y: anchorageViewFrame.origin.y)
        //print("Anchorage :: \(anchorageOffset)")

        let dimensionViewFrame = dimensionBaseVw.convert(dimensionBaseVw.bounds, to: scrollVw)
        let dimensionOffset = CGPoint(x: 0, y: dimensionViewFrame.origin.y)
        //print("Dimension :: \(dimensionOffset)")

        
        if (self.scrollLastContentOffset > scrollVw.contentOffset.y) {
            //print("Scrolling Up...")
        }
        else if (self.scrollLastContentOffset < scrollVw.contentOffset.y) {
            //print("Scrolling Down...")
        }

        //-> update the new position acquired
        self.scrollLastContentOffset = scrollVw.contentOffset.y
//        print("Scroll Offset :: \(self.scrollLastContentOffset), Window: \(windowOffset.y), Glass: \(glassOffset.y), Color: \(colorOffset.y), Anchorage: \(anchorageOffset.y), Dimension: \(dimensionOffset.y)")
        
        self.carosalfunction(isHidden: true)
        if self.scrollLastContentOffset >= windowOffset.y && self.scrollLastContentOffset <= addInsectMeshOffset.y {
//            self.titleLabel.text = "Select Window"
            selectOption = 1
            self.carosalfunction(isHidden: false)
//            if self.isWindowProceed() {
//                print("Proceed ahead.")
//            } else {
//                self.showAlert(title: "Alert", message: "Please select any one swing side.")
//            }
        }
        else if self.scrollLastContentOffset >= addInsectMeshOffset.y && self.scrollLastContentOffset <= glassOffset.y {
            selectOption = 2
        }
        else if self.scrollLastContentOffset >= glassOffset.y && self.scrollLastContentOffset <= colorOffset.y {
//            self.titleLabel.text = "Select Glass"
            selectOption = 3
        }
        else if self.scrollLastContentOffset >= colorOffset.y && self.scrollLastContentOffset <= anchorageOffset.y {
//            self.titleLabel.text = "Select Colors"
            selectOption = 4
        }
        else if self.scrollLastContentOffset >= anchorageOffset.y && self.scrollLastContentOffset <= dimensionOffset.y {
//            self.titleLabel.text = "Select Anchorage"
            selectOption = 5
        }
        else {
//            self.titleLabel.text = "Select Dimension"
            selectOption = 6
        }
        
        
        //NOTE: 85.0 is scrolling scroll offset different with DimensionOffset.y || dimensionOffset.y - 1 if define because next button enable-disable managed.
//        let different = dimensionOffset.y - self.scrollLastContentOffset
        if (self.scrollLastContentOffset + 85) > (dimensionOffset.y - 1) {
            //Button Disable...
            self.nextButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        } else {
            //Button Enable...
            self.nextButton.backgroundColor = UIColor(hex: "008BBF", alpha: 1.0)
        }
    }
}

extension CustomizationVC: UITextFieldDelegate {
    @objc func widthDimentionTxtFieldDidChange(_ textField: UITextField) {
        let width = Double(self.widthDimentionTxtField.text ?? "") ?? 0.0
        let minWidth = Double(self.windowProductsArr[self.windowSelectedIndex].minWidth ?? "") ?? 0.0
        let maxWidth = Double(self.windowProductsArr[self.windowSelectedIndex].maxWidth ?? "") ?? 0.0

        if (self.widthDimentionTxtField.text ?? "").elementsEqual("") {
            self.dimensionWidthErrorLbl.text = ""
        } else {
            if width < minWidth {
                self.dimensionWidthErrorLbl.text = "Please select a width from the range below"
            }
            else if width > maxWidth {
                self.dimensionWidthErrorLbl.text = "Please select a width from the range below"
            }
            else {
                self.dimensionWidthErrorLbl.text = ""
            }
        }
    }
    
    @objc func heightDimentionTxtFieldDidChange(_ textField: UITextField) {
        let height = Double(self.heightDimentionTxtField.text ?? "") ?? 0.0
        let minHeight = Double(self.windowProductsArr[self.windowSelectedIndex].minHeight ?? "") ?? 0.0
        let maxHeight = Double(self.windowProductsArr[self.windowSelectedIndex].maxHeight ?? "") ?? 0.0

        if (self.heightDimentionTxtField.text ?? "").elementsEqual("") {
            self.dimensionHeightErrorLbl.text = ""
        } else {
            if height < minHeight {
                self.dimensionHeightErrorLbl.text = "Please select a height from the range below"
            }
            else if height > maxHeight {
                self.dimensionHeightErrorLbl.text = "Please select a height from the range below"
            }
            else {
                self.dimensionHeightErrorLbl.text = ""
            }
        }
    }
}

// MARK: - Product List API Protocol
protocol WindowDataAPIProtocol {
    func getData(category_id: Int, cart_id: String, completion: @escaping ((CustomizeDataModel?) -> Void))
}

struct WindowDataAPI: WindowDataAPIProtocol {
    func getData(category_id: Int, cart_id: String, completion: @escaping ((CustomizeDataModel?) -> Void)) {
        AppDelegate.shared.netWorker.callAPIService(type: .productList(category_id: category_id, cart_id: cart_id)) { (data: CustomizeDataModel?) in
            completion(data)
        }
    }
}
