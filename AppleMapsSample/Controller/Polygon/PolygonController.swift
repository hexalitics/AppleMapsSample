//
//  PolyGonController.swift
//  AppleMapsSample
//
//  Created by Lucky on 12/04/23.
//

import MapKit
import Combine
import UIKit

class PolygonController: UIViewController {
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension PolygonController {
  
  private func initialSetup() {
    configureNavigation()
    configureView()
    configureMapView()
    configureUserButton()
    configureMapTypeContainerView()
    configureMapType()
    bind()
    requestLocation()
  }
  
  private func configureView() {
    view.backgroundColor = .white
  }
  
  private func configureMapView() {
    MapSubView.configureMapView(
      mapView: mapView,
      view: self.view
    )
  }
  
  private func configureNavigation() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = .white
    navigationController?.navigationBar.standardAppearance = appearance
    title = feature.value.title
  }
  
  private func configureUserButton() {
    MapSubView.configureUserButton(
      mapView: mapView,
      mapTypeButton: mapTypeButton
    )
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
}

//MARK: - Map Types

extension PolygonController {
  
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

extension PolygonController {
  
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
