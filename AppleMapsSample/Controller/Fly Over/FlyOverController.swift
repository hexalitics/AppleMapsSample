//
//  FlyOverController.swift
//  AppleMapsSample
//
//  Created by Lucky on 08/04/23.
//

import UIKit
import MapKit
import Combine

class FlyOverController: UIViewController {
  
  // MARK: - Public Properties
  
  var feature = CurrentValueSubject<Features, Never>(.pin)
  
  // MARK: - Private Properties
  
  private var cancellable = Set<AnyCancellable>()
  private var mapView: MKMapView = MKMapView()
  private var mapTypeContainer: UIView = UIView()
  private var typeContainerView: UIView = UIView()
  private var mapTypeButton: UIButton = UIButton()
  private var standardButton: UIButton = UIButton()
  private var satelliteButton: UIButton = UIButton()
  private var hybridButton: UIButton = UIButton()
  private var destinationButton: UIButton = UIButton()
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension FlyOverController {
  
  private func initialSetup() {
    configureNavigation()
    configureView()
    configureMapView()
    configureUserButton()
    configureMapTypeContainerView()
    configureMapType()
    configureDestinationButton()
    bind()
    startMapView()
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
  
  private func configureDestinationButton() {
    mapView.addSubview(destinationButton)
    destinationButton.translatesAutoresizingMaskIntoConstraints = false
    destinationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    destinationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
    destinationButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
    destinationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    destinationButton.setTitle("  Destination Address", for: .normal)
    destinationButton.layer.cornerRadius = 5
    destinationButton.setTitleColor(.systemGray2, for: .normal)
    destinationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    destinationButton.contentHorizontalAlignment = .left
    destinationButton.backgroundColor = .white
  }
  
  private func configureSearchControllers(_ searchController: SearchController) {
    searchController.closure = { [weak self] str, addressCordinate in
      guard
        let self,
        let addressCordinate,
        let userLocation = self.locationManager.location?.coordinate,
        let str else {
        return
      }
      
      self.animate(latitude: userLocation.latitude, endLatitude: addressCordinate.latitude)
      self.destinationButton.setTitle("  \(str)", for: .normal)
      self.destinationButton.setTitleColor(.black, for: .normal)
      print(userLocation)
      print(str, addressCordinate)
    }
  }
  
  func startMapView() {
    guard
      let userLocation = self.locationManager.location?.coordinate
    else {
      return
    }
    
    let mapcamera = MKMapCamera(lookingAtCenter: userLocation, fromDistance: 500, pitch: 60, heading: 0.0)
    mapView.mapType = .standard
    mapView.camera = mapcamera
  }
  
  func animate(latitude: Double, endLatitude: Double) {
    var currentLatitude = latitude
    let increment = 0.00005
    let _ = Timer.scheduledTimer(withTimeInterval: (1.0/30.0), repeats: true) { (timer) in
      currentLatitude += increment
      if currentLatitude >= endLatitude {
        timer.invalidate()
      }
      self.mapView.camera.centerCoordinate.latitude = currentLatitude
    }
  }
  
  private func requestLocation() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
  }
}

//MARK: - Map Types

extension FlyOverController {
  
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

extension FlyOverController {
  
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
    
    destinationButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.routeToSearch()
      })
      .store(in: &cancellable)
  }
}

//MARK: - Routing Method

extension FlyOverController {
  
  private func routeToSearch() {
    let searchController: SearchController = SearchController()
    configureSearchControllers(searchController)
    push(searchController)
  }
}
