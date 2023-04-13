//
//  MapView.swift
//  AppleMapsSample
//
//  Created by Lucky on 10/04/23.
//

import SwiftUI
import MapKit
import UIKit
import Combine

@available(iOS 16, *)
struct MapView: UIViewRepresentable {
  
  // MARK: - Private Properties
  
  var cancellable = Set<AnyCancellable>()
  typealias UIViewType = MKMapView
  let mapView = MKMapView(frame: .zero)
  let mapTypeButton: UIButton = UIButton()
  var typeContainerView: UIView = UIView()
  var standardButton: UIButton = UIButton()
  var satelliteButton: UIButton = UIButton()
  var hybridButton: UIButton = UIButton()
  
  @Binding var tappedLocation: CLLocationCoordinate2D? // we should bind the user tapped location coordinate object for sending the lookaroundview represen
  
  @StateObject var locationManager = LocationManager()
  
  func makeUIView(context: Context) -> MKMapView {
    mapView.showsUserLocation = true
    MapSubView.configureUserButton(mapView: mapView,
                                   mapTypeButton: mapTypeButton)
    
    MapSubView.configureMapTypeContainerView(typeContainerView: typeContainerView,
                                             mapView: mapView,
                                             standardButton: standardButton,
                                             satelliteButton: satelliteButton,
                                             hybridButton: hybridButton,
                                             mapTypeButton: mapTypeButton)
    let mapTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(MapViewCoordinator.mapTapped(_:)))
    mapView.addGestureRecognizer(mapTap) // creating touch event on the mapview
    configureMapType()
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    if uiView.delegate != nil { return }
    
    if let userLocation = locationManager.userLocation {
      uiView.setRegion(.init(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200), animated: false)
      uiView.delegate = context.coordinator // setting the coordinator to the MkMapView
    }
  }
  
  func makeCoordinator() -> MapViewCoordinator {
    MapViewCoordinator(self, tappedLocation: $tappedLocation)
  }
  
  func setView(hidden: Bool) {
    if hidden {
      UIView.animate(withDuration: 0.5) {
        self.standardButton.frame.origin.y = 0
        self.satelliteButton.frame.origin.y = 60
        self.hybridButton.frame.origin.y = 120
      }
    } else {
      UIView.animate(withDuration: 0.2) {
        self.standardButton.frame.origin.y = 180
        self.satelliteButton.frame.origin.y = 180
        self.hybridButton.frame.origin.y = 180
      }
    }
  }
}

//MARK: - ConfigureMapType

@available(iOS 16, *)
extension MapView {
  
  private func configureMapType() {
    mapTypeButton.addAction {
      if self.standardButton.frame.origin.y == 180 {
        self.setView(hidden: true)
      } else {
        self.setView(hidden: false)
      }
    }
    
    standardButton.addAction {
      let standard = MKStandardMapConfiguration()
      self.mapView.preferredConfiguration = standard
      self.setView(hidden: false)
    }
    
    satelliteButton.addAction {
      self.mapView.preferredConfiguration = MKImageryMapConfiguration()
      
      self.setView(hidden: false)
    }
    
    hybridButton.addAction {
      let hybrid = MKHybridMapConfiguration()
      self.mapView.preferredConfiguration = hybrid
      self.setView(hidden: false)
    }
  }
}
