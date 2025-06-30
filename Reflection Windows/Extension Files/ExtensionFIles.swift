//
//  ExtensionFIles.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/02/24.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat) {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // swiftlint:disable:next control_statement
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        // swiftlint:disable:next control_statement
        if ((cString.count) != 6) {
            //default is white color
            self.init(white: 1.0, alpha: 1.0)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Ensure that the label's attributed text is non-nil
        guard let attributedText = label.attributedText else { return false }

        // Create a layout manager, text storage, and text container for the label
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: label.bounds.size)

        // Configure the text container to match the label's properties
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode

        // Add the text container to the layout manager and the text storage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Get the tapped location in the label
        let locationOfTouch = self.location(in: label)

        // Find the character index at the tapped location
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouch, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // Check if the tapped character is within the target range
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

public extension UIView {
    ///superview is anchored to subview, eg superview.anchor(top: subview.topAnchor)
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        //translate the view's autoresizing mask into Auto Layout constraints
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    // Drop Shadow.....
    func dropShadow(color: UIColor, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 5
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mobileValidation(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        // Regular expression patterns
        let alphabeticPattern = "[A-Za-z]"
        let numericPattern = "[0-9]"
        
        // Check if the password contains at least one alphabetic character
        let alphabeticRange = password.range(of: alphabeticPattern, options: .regularExpression)
        let containsAlphabetic = alphabeticRange != nil
        
        // Check if the password contains at least one numeric character
        let numericRange = password.range(of: numericPattern, options: .regularExpression)
        let containsNumeric = numericRange != nil
        
        // Return true if both conditions are met
        return containsAlphabetic && containsNumeric
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension String {
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,100}").evaluate(with: self)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return nil
        }
    }
}



public extension UIAlertController {

    class func showAlert(titleString: String?, messageString: String? = "", actionString: String? = "OK", viewController: UIViewController?=nil, action: ((UIAlertAction) -> ())? = nil) {

    let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: action))

    if (viewController != nil) {
        viewController!.present(alertController, animated: true, completion: nil)

    } else {
        let window = UIApplication.shared.delegate?.window
        let vc = window??.rootViewController?.presentedViewController ?? window??.rootViewController
        vc?.present(alertController, animated: true, completion: nil)
    }

    }
}



//Object Save & Get from User Defaults....
extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

struct UserDetails: Codable {
    var token: String?
    var fullName: String?
    var mobileNo: String?
    var email: String?
    var dob: String?
    var avtar: String?
    var userID: Int?
}

extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
