//
//  MapSubView.swift
//  AppleMapsSample
//
//  Created by Lucky on 11/04/23.
//

import Foundation
import MapKit
import Combine
import UIKit

class MapSubView {
  
  static func configureUserButton(
    mapView: MKMapView,
    mapTypeButton: UIButton)
  {
    let userButton = MKUserTrackingButton(mapView: mapView)
    mapView.addSubview(userButton)
    userButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
    userButton.layer.borderColor = UIColor.white.cgColor
    userButton.layer.borderWidth = 1
    userButton.layer.cornerRadius = 5
    userButton.translatesAutoresizingMaskIntoConstraints = false
    userButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    userButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
    
    mapView.addSubview(mapTypeButton)
    mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
    mapTypeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.trailingAnchor.constraint(equalTo: userButton.trailingAnchor).isActive = true
    mapTypeButton.bottomAnchor.constraint(equalTo: userButton.topAnchor, constant: -10).isActive = true
    mapTypeButton.setImage(UIImage(systemName: "map"), for: .normal)
    mapTypeButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
    mapTypeButton.layer.cornerRadius = 5
  }
  
  static func configureMapTypeContainerView(
    typeContainerView: UIView,
    mapView: MKMapView,
    standardButton: UIButton,
    satelliteButton: UIButton,
    hybridButton: UIButton,
    mapTypeButton: UIButton
  ) {
    typeContainerView.clipsToBounds = true
    mapView.addSubview(typeContainerView)
    typeContainerView.translatesAutoresizingMaskIntoConstraints = false
    typeContainerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    typeContainerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
    typeContainerView.trailingAnchor.constraint(equalTo: mapTypeButton.trailingAnchor).isActive = true
    typeContainerView.bottomAnchor.constraint(equalTo: mapTypeButton.topAnchor).isActive = true
    typeContainerView.layer.cornerRadius = 10
    
    typeContainerView.backgroundColor = .clear
    
    typeContainerView.addSubview(standardButton)
    typeContainerView.addSubview(satelliteButton)
    typeContainerView.addSubview(hybridButton)
    
    standardButton.clipsToBounds = true
    satelliteButton.clipsToBounds = true
    hybridButton.clipsToBounds = true
    
    standardButton.frame = CGRect(x: 0, y: 180, width: 50, height: 50)
    satelliteButton.frame = CGRect(x: 0, y: 180, width: 50, height: 50)
    hybridButton.frame = CGRect(x: 0, y: 180, width: 50, height: 50)
    
    standardButton.layer.cornerRadius = 5
    satelliteButton.layer.cornerRadius = 5
    hybridButton.layer.cornerRadius = 5
    
    standardButton.setBackgroundImage(UIImage(named: "ic_standard"), for: .normal)
    satelliteButton.setBackgroundImage(UIImage(named: "ic_sattelite"), for: .normal)
    hybridButton.setBackgroundImage(UIImage(named: "ic_hybrid"), for: .normal)
  }
  
  static func configureMapView(
    mapView: MKMapView,
    view: UIView
  ) {
    mapView.showsUserLocation = true
    view.addSubview(mapView)
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
  }
}
