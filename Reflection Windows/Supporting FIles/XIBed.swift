//
//  XIBed.swift
//  BaseAppMulti
//
//  Created by Chaitanya Soni on 10/07/20.
//  Copyright © 2020 Chaitanya Soni. All rights reserved.
//

import Foundation
import UIKit

public protocol XIBed {
    static func instantiate() -> Self
}

public extension XIBed where Self: UIViewController {
    static func instantiate() -> Self {
		return Self(nibName: String(describing: self), bundle: Bundle(for: Self.self))
    }
}
