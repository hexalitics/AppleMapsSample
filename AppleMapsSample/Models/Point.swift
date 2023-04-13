//
//  Point.swift
//  AppleMapsSample
//
//  Created by Sadanand Lowanshi on 21/03/23.
//

import Foundation
import CoreLocation

class Point: Codable {
  let counter: Int
  let latitude: Double
  let longitude: Double
  
  var location: CLLocation {
    return CLLocation(latitude: latitude, longitude: longitude)
  }
  
  enum CodingKeys: String, CodingKey {
    case latitude = "lat"
    case longitude = "lon"
    case counter = "counter"
  }
}
