//
//  Nibbed.swift
//  VPM
//
//  Created by Chaitanya Soni on 22/09/20.
//  Copyright © 2020 appic. All rights reserved.
//

import Foundation
import UIKit

public class Nibbed: UIView, NibLoadable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setStyle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setStyle()
    }
    func setStyle() {
        
    }
}

public protocol NibLoadable {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {

    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
		view.backgroundColor = .clear
		view.clipsToBounds = true
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        self.setStyle()
    }
}
