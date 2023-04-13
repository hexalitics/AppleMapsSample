//
//  CustomAnnotationController.swift
//  AppleMapsSample
//
//  Created by Lucky on 12/04/23.
//

import UIKit
import Combine
import MapKit

class CustomAnnotationController: UIViewController {
  
  // MARK: - Public Properties
  
  var feature = CurrentValueSubject<Features, Never>(.pin)
  
  // MARK: - Private Properties
  
  private var cancellable = Set<AnyCancellable>()
  private var mapView = MKMapView()
  private var mapTypeContainer = UIView()
  private var typeContainerView = UIView()
  private var mapTypeButton = UIButton()
  private var standardButton = UIButton()
  private var satelliteButton = UIButton()
  private var hybridButton = UIButton()
  private let locationManager = CLLocationManager()
  
  private var multiCoordinates = [
    CustomAnnotations(
      coordinate: CLLocationCoordinate2D(latitude: 40.70853508993972,
                                         longitude: -73.99341377241268),
      category: 1
    ),
    CustomAnnotations(
      coordinate: CLLocationCoordinate2D(latitude: 40.735347304018084,
                                         longitude: -73.99493986939007),
      category: 2
    ),
    CustomAnnotations(
      coordinate: CLLocationCoordinate2D(latitude: 40.65496644518041,
                                         longitude: -74.0060030858803),
      category: 3
    ),
    CustomAnnotations(
      coordinate: CLLocationCoordinate2D(latitude: 40.69387234771901,
                                         longitude: -74.04399822397299),
      category: 4
    )
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension CustomAnnotationController {
  
  private func initialSetup() {
    configureNavigation()
    configureView()
    configureMapView()
    configureUserButton()
    configureMapTypeContainerView()
    configureMapType()
    bind()
    requestLocation()
    custom()
  }
  
  private func configureView() {
    view.backgroundColor = .white
  }
  
  private func configureMapView() {
    MapSubView.configureMapView(
      mapView: mapView,
      view: self.view
    )
    mapView.showsUserLocation = false
    mapView.delegate = self
  }
  
  private func configureNavigation() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = .white
    navigationController?.navigationBar.standardAppearance = appearance
    title = feature.value.title
  }
  
  private func configureUserButton() {
    mapView.addSubview(mapTypeButton)
    mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
    mapTypeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    mapTypeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
    mapTypeButton.setImage(UIImage(systemName: "map"), for: .normal)
    mapTypeButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
    mapTypeButton.layer.cornerRadius = 5
  }
  
  private func configureMapTypeContainerView() {
    MapSubView.configureMapTypeContainerView(
      typeContainerView: typeContainerView,
      mapView: mapView,
      standardButton: standardButton,
      satelliteButton: satelliteButton,
      hybridButton: hybridButton,
      mapTypeButton: mapTypeButton
    )
  }
  
  private func setView(hidden: Bool) {
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
  
  private func requestLocation() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
  }
  
  private func custom() {
    for coordinate in multiCoordinates {
      let pin = CustomAnnotation(
        coor: coordinate.coordinate,
        categoryId: coordinate.category
      )
      self.mapView.addAnnotation(pin)
    }
    zoomToLocation(location: CLLocationCoordinate2D(
      latitude: 40.69281311028885,
      longitude: -74.01118939136498)
    )
  }
}

//MARK: - Map Types

extension CustomAnnotationController {
  
  private func configureMapType() {
    standardButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        if #available(iOS 16.0, *) {
          let standard = MKStandardMapConfiguration()
          self.mapView.preferredConfiguration = standard
        } else {
          self.mapView.mapType = .standard
        }
        self.setView(hidden: false)
      })
      .store(in: &cancellable)
    
    satelliteButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        if #available(iOS 16.0, *) {
          self.mapView.preferredConfiguration = MKImageryMapConfiguration()
        } else {
          self.mapView.mapType = .satellite
        }
        self.setView(hidden: false)
      })
      .store(in: &cancellable)
    
    hybridButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        if #available(iOS 16.0, *) {
          let hybrid = MKHybridMapConfiguration()
          self.mapView.preferredConfiguration = hybrid
        } else {
          self.mapView.mapType = .hybrid
        }
        self.setView(hidden: false)
      })
      .store(in: &cancellable)
  }
}

//MARK: - Bind Method

extension CustomAnnotationController {
  
  private func bind() {
    bindButton()
  }
  
  private func bindButton() {
    mapTypeButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        if self.standardButton.frame.origin.y == 180 {
          self.setView(hidden: true)
        } else {
          self.setView(hidden: false)
        }
      })
      .store(in: &cancellable)
  }
}

//MARK: - MKMapViewDelegate

extension CustomAnnotationController: MKMapViewDelegate  {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
    
    guard
      let annotations = annotation as? CustomAnnotation
    else {
      return nil
    }
    annotationView.canShowCallout = false
    
    switch annotations.getCategoryId() {
    case 1:
      annotationView.image = UIImage(named: "ic_hospital")
    case 2:
      annotationView.image = UIImage(named: "ic_hotel")
    case 3:
      annotationView.image = UIImage(named: "ic_location")
    case 4:
      annotationView.image = UIImage(named: "ic_custom_location")
      
    default:
      break;
    }
    return annotationView
  }
  
  private func zoomToLocation(
    location : CLLocationCoordinate2D,
    latitudinalMeters:CLLocationDistance = 10000,
    longitudinalMeters:CLLocationDistance = 10000) {
      let region = MKCoordinateRegion(
        center: location,
        latitudinalMeters: latitudinalMeters,
        longitudinalMeters: longitudinalMeters
      )
      mapView.setRegion(region, animated: true)
    }
}
