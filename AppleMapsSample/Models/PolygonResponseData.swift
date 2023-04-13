//
//  PolygonResponseData.swift
//  AppleMapsSample
//
//  Created by Sadanand Lowanshi on 21/03/23.
//

import Foundation

class PolygonResponseData: Codable {
  let type: String
  let coordinates: [[[[Double]]]]
}
