//
//  ResourcesCatTVC.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/03/24.
//

import UIKit
import moa

protocol CollectionViewCellDelegate: AnyObject {
    func didSelectItemAtIndex(urlString: String)
}

class ResourcesCatTVC: UITableViewCell {

    static let indentifier = "ResourcesCatTVC"
    static func nib() -> UINib{
        return UINib(nibName: "ResourcesCatTVC", bundle: nil)
    }
    weak var didSelectDelegate: CollectionViewCellDelegate?
    @IBOutlet weak var categoryCollectionVw: UICollectionView!
    @IBOutlet weak var pageControlUIView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
//    var resources: [ResourceCatDetail] = []
    let itemsPerPage = Constants.Is_iPad ? 3 : 2 // Adjust this based on the number of items visible at once
    var totalPages: Int = 0
    var resources: [ResourceCatDetail] = [] {
        didSet {
            totalPages = (resources.count + itemsPerPage - 1) / itemsPerPage
            pageControl.numberOfPages = totalPages
            categoryCollectionVw.reloadData()
        }
    }
    //var resourcesImg: [String] = []
    var sectionIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        categoryCollectionVw.register(HomeResourcesCVC.nib(), forCellWithReuseIdentifier: HomeResourcesCVC.identifier)
        categoryCollectionVw.register(ResourcesDetailCVC.nib(), forCellWithReuseIdentifier: ResourcesDetailCVC.identifier)
        categoryCollectionVw.delegate = self
        categoryCollectionVw.dataSource = self
        
        categoryCollectionVw.isPagingEnabled = false
        pageControl.numberOfPages = resources.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor.init(hex: "#008BBF", alpha: 1.0)
        pageControl.pageIndicatorTintColor = .white
        pageControl.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ResourcesCatTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.categoryCollectionVw:
            return self.resources.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.categoryCollectionVw:
            
            let cell = categoryCollectionVw.dequeueReusableCell(withReuseIdentifier: ResourcesDetailCVC.identifier, for: indexPath) as! ResourcesDetailCVC
            
            cell.titleLbl.text = self.resources[indexPath.row].name ?? ""
            //cell.imgVw.moa.url = self.resources[indexPath.row].image ?? ""
            
            let urlString = self.resources[indexPath.row].url ?? ""
            if let url = URL(string: urlString) {
                let filePath = url.pathExtension
                if filePath == "mp4" {
                    cell.imgVw.moa.url = self.resources[indexPath.row].image ?? ""
                    cell.playImgVw.isHidden = false
                    
                    cell.pdfImgVw.isHidden = true
                    cell.pdfImgVw.image = nil
                }
                else if filePath == "pdf" {
                    cell.imgVw.image = nil
                    cell.playImgVw.isHidden = true
                    
                    cell.pdfImgVw.isHidden = false
                    cell.pdfImgVw.moa.url = self.resources[indexPath.row].image ?? ""
                }
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case categoryCollectionVw:
//            if self.sectionIndex == 0 {
//                if Constants.Is_iPad {
//                    let width = (self.categoryCollectionVw.frame.size.width - 5) / 2.6
//                    return CGSize(width: width, height: 200)
//                } else {
//                    let width = (self.categoryCollectionVw.frame.size.width - 5) / 2.1
//                    return CGSize(width: width, height: 153)
//                }
//               
//            } else {
//                let height = self.categoryCollectionVw.frame.size.height - 10
//                return CGSize(width: height + 25, height: height)
//            }
//            let height = self.categoryCollectionVw.frame.size.height - 10
//            return CGSize(width: height + 65, height: height + 35)
            let width = (collectionView.frame.width / CGFloat(itemsPerPage)) - 30
            return CGSize(width: width, height: width)
            
        default:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let str = self.resources[indexPath.row].url ?? ""
        didSelectDelegate?.didSelectItemAtIndex(urlString: str)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
//            pageControl.currentPage = Int(pageIndex)
//            print("Page:", pageControl.currentPage)
//    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let pageWidth = scrollView.frame.width
//        // Avoid division by zero
//        guard pageWidth > 0 else { return }
//        let pageIndex = scrollView.contentOffset.x / pageWidth
//        pageControl.currentPage = Int(round(pageIndex))
//        // Debug print to see the value
//        print("Page index: \(pageControl.currentPage)")
        let visibleRect = CGRect(origin: categoryCollectionVw.contentOffset, size: categoryCollectionVw.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let indexPath = categoryCollectionVw.indexPathForItem(at: visiblePoint) {
            pageControl.currentPage = indexPath.row / itemsPerPage
        }
    }
}

