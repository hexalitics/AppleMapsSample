//
//  UIviewController + Extension.swift
//  AppleMapsSample
//
//  Created by Lucky on 22/03/23.
//

import Foundation
import UIKit

extension UIViewController {
  
  func push(_ viewController: UIViewController, animated: Bool = true) {
    navigationController?.pushViewController(viewController, animated: animated)
  }
}
