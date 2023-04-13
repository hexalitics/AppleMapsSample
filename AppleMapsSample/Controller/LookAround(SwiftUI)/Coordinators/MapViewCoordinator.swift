//
//  MapViewCoordinator.swift
//  AppleMapsSample
//
//  Created by Lucky on 10/04/23.
//

import SwiftUI
import MapKit

@available(iOS 16, *)
class MapViewCoordinator: NSObject, MKMapViewDelegate {
  @Binding var tappedLocation: CLLocationCoordinate2D?
  
  var mapViewController: MapView
  
  init(_ mapView: MapView, tappedLocation: Binding<CLLocationCoordinate2D?>) {
    self.mapViewController = mapView
    self._tappedLocation = tappedLocation
  }
  
  @objc func mapTapped(_ sender: UITapGestureRecognizer) {
    guard let mapView = sender.view as? MKMapView else { return }
    
    let touchLocation = sender.location(in: sender.view) // getting the user touch location
    
    let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: sender.view) // converting the touch location into the real map location
    
    let annotation = MKPointAnnotation() // creating the new annotation instance
    annotation.coordinate = .init(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude) // setting the user touch location to annotation
    
    self.tappedLocation = locationCoordinate
    
    mapView.removeAnnotations(mapView.annotations) // clearing the previous annotation
    
    mapView.addAnnotation(annotation) // adding the user tapped location annotation
  }
}
