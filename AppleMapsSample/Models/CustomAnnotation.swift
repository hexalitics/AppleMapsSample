//
//  CustomAnnotation.swift
//  AppleMapsSample
//
//  Created by Lucky on 03/04/23.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var categoryId: Int
  
  // 4
  init(coor: CLLocationCoordinate2D, categoryId: Int)
  {
    coordinate = coor
    self.categoryId = categoryId
  }
  
  func getCategoryId() -> Int {
      return categoryId
  }
}


