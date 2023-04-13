//
//  Features.swift
//  AppleMapsSample
//
//  Created by Lucky on 22/03/23.
//

import Foundation
import UIKit

enum Features {
  case polygon
  case pin
  case polyline
  case route
  case custom
  case flyOver
  case lookAround
}

extension Features {
  
  var title: String {
    switch self {
    case .polygon:
      return "Polygon"
      
    case .pin:
      return "Drop pin"
      
    case .polyline:
      return "Polyline"
      
    case .route:
      return "Route & Directions"
      
    case .custom:
      return "Custom Annotation"
      
    case .flyOver:
      return "Fly Over"
      
    case .lookAround:
      return "Look Around"
    }
  }
  
  var icon: String {
    switch self {
    case .polygon:
      return  "map.fill"
      
    case .pin:
      return  "mappin.and.ellipse"
      
    case .polyline:
      return "line.diagonal"
      
    case .route:
      return "arrow.triangle.turn.up.right.diamond.fill"
      
    case .custom:
      return "ic_custom_annotaion"
      
    case .flyOver:
      return "paperplane"
      
    case .lookAround:
      return "eye"
    }
  }
  
  var iconColor: UIColor {
    switch self {
    case .polygon:
      return .systemOrange
      
    case .pin:
      return .systemRed
      
    case .polyline:
      return .systemPurple
      
    case .route:
      return .systemBlue
      
    case .custom:
      return .systemGray
      
    case .flyOver:
      return .gray
      
    case .lookAround:
      if #available(iOS 15.0, *) {
        return .systemCyan
      } else {
        return .cyan
      }
    }
  }
}
