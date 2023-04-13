//
//  Extension + UItextfield.swift
//  AppleMapsSample
//
//  Created by Lucky on 24/03/23.
//

import Foundation
import UIKit
import Combine

extension UITextField {
  
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField } // receiving notifications with objects which are instances of UITextFields
            .compactMap(\.text) // extracting text and removing optional values (even though the text cannot be nil)
            .eraseToAnyPublisher()
    }
}
