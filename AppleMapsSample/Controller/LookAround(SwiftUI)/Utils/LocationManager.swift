//
//  LocationManager.swift
//  AppleMapsSample
//
//  Created by Lucky on 10/04/23.
//

import SwiftUI
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  
  @Published var userLocation: CLLocationCoordinate2D?
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if userLocation != nil { return }
    
    guard let location = locations.last else { return }
    
    userLocation = location.coordinate
  }
}
