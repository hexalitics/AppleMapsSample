//
//  TraceResponseData.swift
//  AppleMapsSample
//
//  Created by Sadanand Lowanshi on 21/03/23.
//

import Foundation

class TraceResponseData: Codable {
  let routes: [[Point]]
  
  enum CodingKeys: String, CodingKey {
    case routes = "array_of_routes"
  }
}
