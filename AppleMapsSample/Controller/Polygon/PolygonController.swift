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
  
  var points = [CLLocationCoordinate2D](){
    didSet {
      print(points)
    }
  }
  
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
    mapView.delegate = self
    mapView.isUserInteractionEnabled = false
  }
  
  private func configureNavigation() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = .white
    navigationController?.navigationBar.standardAppearance = appearance
    title = feature.value.title
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  private func configureUserButton() {
    let userButton = MKUserTrackingButton(mapView: mapView)
    view.addSubview(userButton)
    userButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
    userButton.layer.borderColor = UIColor.white.cgColor
    userButton.layer.borderWidth = 1
    userButton.layer.cornerRadius = 5
    userButton.translatesAutoresizingMaskIntoConstraints = false
    userButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    userButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
    
    view.addSubview(mapTypeButton)
    mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
    mapTypeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    mapTypeButton.trailingAnchor.constraint(equalTo: userButton.trailingAnchor).isActive = true
    mapTypeButton.bottomAnchor.constraint(equalTo: userButton.topAnchor, constant: -10).isActive = true
    mapTypeButton.setImage(UIImage(systemName: "map"), for: .normal)
    mapTypeButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
    mapTypeButton.layer.cornerRadius = 5
  }
  
  private func configureMapTypeContainerView() {
    typeContainerView.clipsToBounds = true
    view.addSubview(typeContainerView)
    typeContainerView.translatesAutoresizingMaskIntoConstraints = false
    typeContainerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    typeContainerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
    typeContainerView.trailingAnchor.constraint(equalTo: mapTypeButton.trailingAnchor).isActive = true
    typeContainerView.bottomAnchor.constraint(equalTo: mapTypeButton.topAnchor).isActive = true
    typeContainerView.layer.cornerRadius = 10
    
    typeContainerView.backgroundColor = .clear
    
    typeContainerView.addSubview(satelliteButton)
    typeContainerView.addSubview(standardButton)
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
  
  private func setView(hidden: Bool) {
    if hidden {
      UIView.animate(withDuration: 0.5) {
        self.satelliteButton.frame.origin.y = 0
        self.standardButton.frame.origin.y = 60
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
        guard let self else {
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
        guard let self else {
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
        guard let self else {
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
        guard let self else {
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

extension PolygonController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = .orange
      polylineRenderer.lineWidth = 5
      return polylineRenderer
    } else if overlay is MKPolygon {
      let polygonView = MKPolygonRenderer(overlay: overlay)
      polygonView.fillColor = .magenta
      return polygonView
    }
    return MKPolylineRenderer(overlay: overlay)
  }
}

//MARK: - Touch Event

extension PolygonController {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    mapView.removeOverlays(mapView.overlays) //Reset shapes
    if let touch = touches.first {
      let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
      points.append(coordinate)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
      points.append(coordinate)
      let polyline = MKPolyline(coordinates: points, count: points.count)
      mapView.addOverlay(polyline) //Add lines
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let polygon = MKPolygon(coordinates: &points, count: points.count)
    mapView.addOverlay(polygon)
    
    //Add polygon areas
    points = [] //Reset points
  }
}
