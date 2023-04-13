//
//  RouteDirectionController.swift
//  AppleMapsSample
//
//  Created by Lucky on 12/04/23.
//

import MapKit
import Combine
import UIKit
import AVFoundation

class RouteDirectionController: UIViewController {
  
  // MARK: - Public Properties
  
  var feature = CurrentValueSubject<Features, Never>(.pin)
  
  // MARK: - Private Properties
  
  private var cancellable = Set<AnyCancellable>()
  
  private var descriptionContainerView: UIView = UIView()
  private var mapTypeContainer: UIView = UIView()
  private var typeContainerView: UIView = UIView()
  private let arrowImageView: UIImageView = UIImageView()
  
  private let searchAddressButton: UIButton = UIButton()
  private var showRouteButton: UIButton = UIButton()
  private var mapTypeButton: UIButton = UIButton()
  private var standardButton: UIButton = UIButton()
  private var satelliteButton: UIButton = UIButton()
  private var hybridButton: UIButton = UIButton()
  private var startnavigateButton: UIButton = UIButton()
  private let descriptionLabel: UILabel = UILabel()
  
  private var mapView: MKMapView = MKMapView()
  private let locationManager = CLLocationManager()
  
  private var route: MKRoute?
  private var steps: [MKRoute.Step] = []
  private var speechSynthesizer = AVSpeechSynthesizer()
  private let annotation = MKPointAnnotation()
  private var stepCounter = 0
  
  private let startNavigateTap = PassthroughSubject<Void, Never>()
  private var navigationStarted = CurrentValueSubject<Bool, Never>(false)
  private var showMapRoute = CurrentValueSubject<Bool, Never>(false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension RouteDirectionController {
  
  private func initialSetup() {
    configureView()
    configureNavigation()
    configureConstraintSetup()
    requestLocation()
    configureMapType()
    bind()
  }
  
  private func configureView() {
    view.backgroundColor = .white
  }
  
  private func configureNavigation() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = .white
    navigationController?.navigationBar.standardAppearance = appearance
    title = feature.value.title
  }
  
  private func configureConstraintSetup() {
    configureContainerView()
    configureArrowImageView()
    configureDescriptionLabel()
    configureMapView()
    configureRouteButton()
    configureResetButton()
    configureUserButton()
    configureDestinationButton()
    configureMapTypeContainerView()
  }
  
  private func configureContainerView() {
    view.addSubview(descriptionContainerView)
    descriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
    descriptionContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
  }
  
  private func configureArrowImageView() {
    descriptionContainerView.addSubview(arrowImageView)
    arrowImageView.translatesAutoresizingMaskIntoConstraints = false
    arrowImageView.isHidden = true
    arrowImageView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -10).isActive = true
    arrowImageView.centerYAnchor.constraint(equalTo: descriptionContainerView.centerYAnchor).isActive = true
    arrowImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
    arrowImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
    arrowImageView.image = UIImage(systemName: "chevron.right")
    arrowImageView.tintColor = .gray
  }
  
  private func configureDescriptionLabel() {
    descriptionContainerView.addSubview(descriptionLabel)
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor).isActive = true
    descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 20).isActive = true
    descriptionLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -20).isActive = true
    descriptionLabel.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor).isActive = true
    descriptionLabel.text = "Where do you want to go?"
    descriptionLabel.numberOfLines = 0
  }
  
  private func configureRouteButton() {
    showRouteButton.isUserInteractionEnabled = false
    descriptionContainerView.addSubview(showRouteButton)
    showRouteButton.translatesAutoresizingMaskIntoConstraints = false
    showRouteButton.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor).isActive = true
    showRouteButton.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor).isActive = true
    showRouteButton.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor).isActive = true
    showRouteButton.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor).isActive = true
  }
  
  private func configureResetButton() {
    self.mapView.addSubview(startnavigateButton)
    startnavigateButton.translatesAutoresizingMaskIntoConstraints = false
    startnavigateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    startnavigateButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
    startnavigateButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    startnavigateButton.setTitle("Start navigation", for: .normal)
    startnavigateButton.widthAnchor.constraint(equalToConstant: 170).isActive = true
    
    startnavigateButton.layer.cornerRadius = 10
    startnavigateButton.backgroundColor = .systemGray2
    startnavigateButton.isUserInteractionEnabled = false
  }
  
  private func configureDestinationButton() {
    mapView.addSubview(searchAddressButton)
    searchAddressButton.translatesAutoresizingMaskIntoConstraints = false
    searchAddressButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    searchAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
    searchAddressButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
    searchAddressButton.topAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 20).isActive = true
    searchAddressButton.setTitle("  Search Address", for: .normal)
    searchAddressButton.layer.cornerRadius = 5
    searchAddressButton.setTitleColor(.systemGray2, for: .normal)
    searchAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    searchAddressButton.contentHorizontalAlignment = .left
    searchAddressButton.backgroundColor = .white
  }
  
  private func configureMapView() {
    mapView.delegate = self
    mapView.showsUserLocation = true
    view.addSubview(mapView)
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.topAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 10).isActive = true
    mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
  
  private func requestLocation() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
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
}

//MARK: - Start Stop Navigation

extension RouteDirectionController {
  
  private func navigationButtonTapped() {
    if navigationStarted.value {
      showMapRoute.value = true
      if let center = locationManager.location?.coordinate {
        centerViewToUserLocation(center: center)
      }
    } else {
      if let route = route {
        self.mapView.setVisibleMapRect(
          route.polyline.boundingMapRect,
          edgePadding: UIEdgeInsets(top: 16,
                                    left: 16,
                                    bottom: 16,
                                    right: 16
                                   ),
          animated: true)
        //        self.steps.removeAll()
        self.stepCounter = 0
      }
    }
  }
  
  private func centerViewToUserLocation(center: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: center,
                                    latitudinalMeters: 500,
                                    longitudinalMeters: 500
    )
    mapView.setRegion(region,
                      animated: true
    )
  }
}

//MARK: - Show Route

extension RouteDirectionController {
  
  private func showRouteOnMap(
    pickupCoordinate: CLLocationCoordinate2D,
    destinationCoordinate: CLLocationCoordinate2D
  ) {
    let request = MKDirections.Request()
    request.source = MKMapItem(
      placemark: MKPlacemark(coordinate: pickupCoordinate,
                             addressDictionary: nil)
    )
    request.destination = MKMapItem(
      placemark: MKPlacemark(coordinate: destinationCoordinate,
                             addressDictionary: nil)
    )
    request.transportType = .automobile
    let directions = MKDirections(request: request)
    
    directions.calculate { [unowned self] response, error in
      guard
        let response = response
      else {
        print("Error: \(error?.localizedDescription ?? "No error specified").")
        return
      }
      
      let route = response.routes[0]
      self.route = route
      self.mapView.addOverlay(route.polyline)
      
      self.mapView.setVisibleMapRect(
        route.polyline.boundingMapRect,
        edgePadding: UIEdgeInsets.init(top: 16.0,
                                       left: 16.0,
                                       bottom: 16.0,
                                       right: 16.0),
        animated: true
      )
      self.getRouteSteps(route: route)
    }
  }
  
  private func getRouteSteps(route: MKRoute) {
    for monitorRegion in locationManager.monitoredRegions {
      locationManager.stopMonitoring(for: monitorRegion)
    }
    
    let steps = route.steps
    self.steps = steps
    
    for i in 1..<steps.count {
      let step = steps[i]
      print(step.instructions)
      print(step.distance)
      
      let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20,
                                    identifier: "\(i)"
      )
      locationManager.startMonitoring(for: region)
    }
    stepCounter += 1
    
    let distanceFirst = steps[stepCounter].distance
    let stepFirstDistance = Double(round(10 * distanceFirst) / 10)
    
    let distanceSecond = steps[stepCounter + 1].distance
    let stepSecondDistance = Double(round(10 * distanceSecond) / 10)
    
    let initialmessage = "In \(stepFirstDistance) meter \(steps[stepCounter].instructions), then in \(stepSecondDistance) meters, \(steps[stepCounter + 1].instructions)"
    descriptionLabel.text = initialmessage
    arrowImageView.isHidden = false
    showRouteButton.isUserInteractionEnabled = true
    let speechUtterance = AVSpeechUtterance(string: initialmessage)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    speechUtterance.rate = 0.5
    speechSynthesizer.usesApplicationAudioSession = false
    speechSynthesizer.speak(speechUtterance)
  }
}

//MARK: - SearchController

extension RouteDirectionController {
  private func configureSearchController(searchController: SearchController) {
    searchController.closure = { [weak self] str, addressCordinate in
      guard
        let self,
        let addressCordinate,
        let userLocation = self.locationManager.location?.coordinate,
        let str else {
        return
      }
      self.searchAddressButton.setTitle("  \(str)", for: .normal)
      self.searchAddressButton.setTitleColor(.black, for: .normal)
      self.searchAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
      
      self.showRouteOnMap(pickupCoordinate: userLocation,
                          destinationCoordinate: addressCordinate
      )
      
      self.annotation.coordinate = addressCordinate
      self.mapView.addAnnotation(self.annotation)
      
      if !str.isEmpty {
        self.startnavigateButton.backgroundColor = .systemRed
        self.startnavigateButton.isUserInteractionEnabled = true
      }
      
      self.mapView.removeOverlays(self.mapView.overlays)
    }
  }
}

//MARK: - Map Types

extension RouteDirectionController {
  
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

extension RouteDirectionController {
  
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
    
    startNavigateTap
      .sink { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.navigationStarted.value.toggle()
        self.navigationButtonTapped()
        self.startnavigateButton.setTitle(self.navigationStarted.value ? "Stop navigation" : "Start navigation", for: .normal)
        self.startnavigateButton.isUserInteractionEnabled = true
        self.startnavigateButton.backgroundColor = .systemRed
        if !self.navigationStarted.value {
          self.locationManager.stopUpdatingLocation()
        }
      }
      .store(in: &cancellable)
    
    showRouteButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.routeToRoutesController()
      })
      .store(in: &cancellable)
    
    searchAddressButton
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
    
    startnavigateButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.startNavigateTap.send()
      })
      .store(in: &cancellable)
  }
}

//MARK: - MKMapViewDelegate

extension RouteDirectionController: MKMapViewDelegate  {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    polylineRenderer.strokeColor = .systemBlue
    polylineRenderer.lineWidth = 4
    return polylineRenderer
  }
}

//MARK: - CLLocationManagerDelegate

extension RouteDirectionController: CLLocationManagerDelegate {
  
  private func location() {
    locationManager.startUpdatingLocation()
    requestLocation()
    configureLocation()
  }
  
  private func configureLocation() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if showMapRoute.value {
      if let location = locations.last {
        let coordinate = location.coordinate
        centerViewToUserLocation(center: coordinate)
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    stepCounter += 1
    if stepCounter <= steps.count {
      let distance = steps[stepCounter].distance
      let stepDistance = Double(round(100 * distance) / 100)
      let message = "In \(stepDistance) meter \(steps[stepCounter].instructions)"
      descriptionLabel.text = message
      arrowImageView.isHidden = false
      showRouteButton.isUserInteractionEnabled = true
      let speechUtterance = AVSpeechUtterance(string: message)
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
      speechUtterance.rate = 0.5
      speechSynthesizer.usesApplicationAudioSession = false
      speechSynthesizer.speak(speechUtterance)
    } else {
      let message = "You have arrived at your destination"
      descriptionLabel.text = message
      arrowImageView.isHidden = false
      showRouteButton.isUserInteractionEnabled = true
      let speechUtterance = AVSpeechUtterance(string: message)
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
      speechUtterance.rate = 0.5
      speechSynthesizer.usesApplicationAudioSession = false
      speechSynthesizer.speak(speechUtterance)
      stepCounter = 0
      navigationStarted.value = false
      for monitoredRegion in locationManager.monitoredRegions {
        locationManager.stopMonitoring(for: monitoredRegion)
      }
    }
  }
}

//MARK: - Routing Method

extension RouteDirectionController {
  
  private func routeToSearch() {
    let searchController: SearchController = SearchController()
    configureSearchController(searchController: searchController)
    push(searchController)
  }
  
  private func routeToRoutesController() {
    let routesController: RoutesController = RoutesController()
    routesController.steps = steps
    push(routesController)
  }
}
