//
//  DropPinController.swift
//  AppleMapsSample
//
//  Created by Lucky on 12/04/23.
//

import MapKit
import Combine
import UIKit

class DropPinController: UIViewController {
  
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
  private var resetButton: UIButton = UIButton()
  private let locationManager = CLLocationManager()
  private let resetButtontap = PassthroughSubject<Void, Never>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension DropPinController {
  
  private func initialSetup() {
    configureNavigation()
    configureView()
    configureMapView()
    configureUserButton()
    configureMapTypeContainerView()
    configureMapType()
    bind()
    requestLocation()
    configureDropPinAndPolyline()
    configureResetButton()
  }
  
  private func configureResetButton() {
    self.mapView.addSubview(resetButton)
    resetButton.translatesAutoresizingMaskIntoConstraints = false
    resetButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    resetButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
    resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    resetButton.setTitle("Reset all", for: .normal)
    resetButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
    
    resetButton.layer.cornerRadius = 10
    resetButton.backgroundColor = .systemGray2
    resetButton.isUserInteractionEnabled = false
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

extension DropPinController {
  
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

extension DropPinController {
  
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
    
    resetButtontap
      .sink { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.resetButton.backgroundColor = .systemGray2
        self.resetButton.isUserInteractionEnabled = false
      }
      .store(in: &cancellable)
  }
  
  private func resetButton(annotation: MKPointAnnotation) {
    resetButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.mapView.removeAnnotation(annotation)
        self.resetButtontap.send()
      })
      .store(in: &cancellable)
  }
}

//MARK: - UIGestureRecognizerDelegate

extension DropPinController: UIGestureRecognizerDelegate {
  
  private func configureDropPinAndPolyline() {
    let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                         action: #selector(handleTap)
    )
    gestureRecognizer.delegate = self
    mapView.addGestureRecognizer(gestureRecognizer)
  }
  
  @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
    let location = gestureRecognizer.location(in: mapView)
    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    
    // Add annotation
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
    
    resetButton(annotation: annotation)
    if !mapView.annotations.isEmpty {
      resetButton.backgroundColor = .systemRed
      resetButton.isUserInteractionEnabled = true
    }
  }
}
