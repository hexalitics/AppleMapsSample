//
//  MapViewController.swift
//  AppleMapsSample
//
//  Created by Lucky on 22/03/23.
//

import UIKit
import MapKit
import CoreLocation
import Combine
import AVFoundation
import SwiftUI

class MapViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var descriptionContainerView: UIView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var arrowImageView: UIImageView!
  @IBOutlet weak var showRouteButton: UIButton!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapTypeButton: UIButton!
  @IBOutlet weak var mapTypeContainerView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var searchTextFieldContainer: UIView!
  
  // MARK: - Public Properties
  
  var feature = CurrentValueSubject<Features, Never>(.pin)
  
  // MARK: - Private Properties
  
  private var cancellable = Set<AnyCancellable>()
  private let resetButtontap = PassthroughSubject<Void, Never>()
  private let locationManager = CLLocationManager()
  private var coordinates = CurrentValueSubject<[CLLocationCoordinate2D], Never>([])
  private let annotation = MKPointAnnotation()
  private var isSelected = CurrentValueSubject<Bool, Never>(false)
  private var showMapRoute = CurrentValueSubject<Bool, Never>(false)
  private var navigationStarted = CurrentValueSubject<Bool, Never>(false)
  private var steps: [MKRoute.Step] = []
  private var route: MKRoute?
  private var speechSynthesizer = AVSpeechSynthesizer()
  private var stepCounter = 0
  private var button: UIButton = UIButton()
  private var typeContainerView: UIView = UIView()
  private var standardButton: UIButton = UIButton()
  private var satelliteButton: UIButton = UIButton()
  private var hybridButton: UIButton = UIButton()
  
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
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetUp()
  }
}

//MARK: - Private Method

extension MapViewController {
  
  private func initialSetUp() {
    configureNavigation()
    configureView()
    configureMap()
    configureButton()
    bind()
    location()
    featureType()
    resetButton(annotation: MKPointAnnotation())
    configureMapType()
    configureMapTypeContainerView()
    configureUserButton()
  }
  
  private func configureNavigation() {
    title = feature.value.title
  }
  
  private func configureView() {
    mapTypeContainerView.alpha = 0.8
    mapTypeContainerView.layer.cornerRadius = 5
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
  
  private func configureButton() {
    self.mapView.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    button.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
    button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50).isActive = true
    
    if feature.value == .route {
      button.setTitle(navigationStarted.value ? "Stop navigation" : "Start navigation", for: .normal)
      button.widthAnchor.constraint(equalToConstant: 170).isActive = true
    } else {
      self.button.setTitle("Reset all", for: .normal)
      button.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    self.button.layer.cornerRadius = 10
    self.button.backgroundColor = .systemGray2
    self.button.isUserInteractionEnabled = false
  }
  
  private func configureUserButton() {
    let userButton = MKUserTrackingButton(mapView: mapView)
    containerView.addSubview(userButton)
    userButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
    userButton.layer.borderColor = UIColor.white.cgColor
    userButton.layer.borderWidth = 1
    userButton.layer.cornerRadius = 5
    userButton.translatesAutoresizingMaskIntoConstraints = false
    userButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    userButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    userButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    userButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
    userButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
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
  
  private func navigationButtonTapped() {
    if navigationStarted.value {
      showMapRoute.value = true
      if let center = locationManager.location?.coordinate {
        centerViewToUserLocation(center: center)
      }
    } else {
      if let route = route {
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
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
  
  private func configureSearchController(searchController: SearchController) {
    searchController.closure = { [weak self] str, addressCordinate in
      guard
        let self,
        let addressCordinate,
        let userLocation = self.locationManager.location?.coordinate,
        let str else {
        return
      }
      self.searchTextField.text = str
      
      self.showRouteOnMap(pickupCoordinate: userLocation,
                          destinationCoordinate: addressCordinate
      )
      self.annotation.coordinate = addressCordinate
      self.mapView.addAnnotation(self.annotation)
      
      if !str.isEmpty {
        self.button.backgroundColor = .systemRed
        self.button.isUserInteractionEnabled = true
      }
      
      self.mapView.removeOverlays(self.mapView.overlays)
    }
    self.isSelected.value = true
  }
}

//MARK: - Map Types

extension MapViewController {
  
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

//MARK: - Features Type

extension MapViewController {
  
  private func featureType() {
    let features = feature.value
    switch features {
    case .polygon:
      polygon()
    case .pin:
      print("FlyOver")
      //      pin()
    case .polyline:
      print("PolyLine")
      //      polyline()
    case .route:
      routeAndDirection()
      
    case .custom:
      print("Custom")
      //      custom()
      
    case .flyOver:
      print("FlyOver")
      
    case .lookAround:
      print("LookAround")
    }
  }
  
  private func polygon() {
    button.isHidden = true
    searchTextFieldContainer.isHidden = true
    descriptionContainerView.isHidden = true
    containerView.isHidden = false
  }
  
  private func pin() {
    button.isHidden = false
    descriptionContainerView.isHidden = true
    searchTextFieldContainer.isHidden = true
    containerView.isHidden = false
    configureDropPinAndPolyline()
  }
  
  private func polyline() {
    button.isHidden = false
    descriptionContainerView.isHidden = true
    searchTextFieldContainer.isHidden = true
    containerView.isHidden = false
    configureDropPinAndPolyline()
  }
  
  private func routeAndDirection() {
    button.isHidden = false
    descriptionContainerView.isHidden = false
    arrowImageView.isHidden = true
    searchTextFieldContainer.isHidden = false
    showRouteButton.isUserInteractionEnabled = false
    containerView.isHidden = false
    descriptionLabel.text = "Where do you want to go?"
  }
  
  private func custom() {
    button.isHidden = true
    descriptionContainerView.isHidden = true
    searchTextFieldContainer.isHidden = true
    containerView.isHidden = true
    
    for coordinate in multiCoordinates {
      let pin = CustomAnnotation(coor: coordinate.coordinate,
                                 categoryId: coordinate.category
      )
      self.mapView.addAnnotation(pin)
    }
    zoomToLocation(location: CLLocationCoordinate2D(latitude: 40.69281311028885,
                                                    longitude: -74.01118939136498)
    )
  }
}

//MARK: - Bind Method

extension MapViewController {
  
  private func bind() {
    bindElements()
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
    
    searchButton
      .tap
      .sink(receiveValue: { [weak self] _ in
        guard
          let self
        else {
          return
        }
        self.routeToSearchController()
        self.mapView.reloadInputViews()
      })
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
  }
  
  /// Subscribes to listeners
  private func bindElements() {
    resetButtontap
      .sink { [weak self] _ in
        guard
          let self
        else {
          return
        }
        if self.feature.value == .route {
          self.navigationStarted.value.toggle()
          self.navigationButtonTapped()
          self.configureButton()
          self.button.isUserInteractionEnabled = true
          self.button.backgroundColor = .systemRed
          if !self.navigationStarted.value {
            self.locationManager.stopUpdatingLocation()
          }
        } else {
          self.mapView.removeOverlays(self.mapView.overlays)
          self.button.backgroundColor = .systemGray2
          self.button.isUserInteractionEnabled = false
          self.coordinates.value.removeAll()
        }
      }
      .store(in: &cancellable)
  }
  
  private func resetButton(annotation: MKPointAnnotation) {
    button
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

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate  {
  
  private func configureMap() {
    mapView.showsUserLocation = true
    mapView.delegate = self
    mapView.mapType = .standard
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
  }
  
  private func getUserAddress(lattitude: Double, longitude: Double) {
    let address = CLGeocoder.init()
    address.reverseGeocodeLocation(CLLocation(latitude: lattitude, longitude: longitude)) { (places, error) in
      if error == nil{
        if let place = places {
          print(place)
        }
      }
    }
  }
  
  private func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
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
  
  private func getLatLongfromAddress() {
    guard
      let address = searchTextField.text
    else {
      return
    }
    
    let geoCoder = CLGeocoder()
    geoCoder.geocodeAddressString(address) { (placemarks, error) in
      guard
        let placemarks = placemarks,
        let location = placemarks.first?.location?.coordinate
      else {
        return
      }
      let userLocation = self.mapView.userLocation.coordinate
      self.showRouteOnMap(pickupCoordinate: userLocation,
                          destinationCoordinate: location
      )
      self.annotation.coordinate = location
      self.mapView.addAnnotation(self.annotation)
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    
    if overlay is MKPolyline {
      polylineRenderer.strokeColor = isSelected.value ? .systemBlue : .systemRed
      polylineRenderer.lineWidth = isSelected.value ? 4 : 3
    }
    return polylineRenderer
  }
  
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
      let region = MKCoordinateRegion(center: location,
                                      latitudinalMeters: latitudinalMeters,
                                      longitudinalMeters: longitudinalMeters
      )
      mapView.setRegion(region, animated: true)
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
  
  private func location() {
    locationManager.startUpdatingLocation()
    requestLocation()
    configureLocation()
  }
  
  private func requestLocation() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
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
      //      let message = "You have arrived at your destination"
      //      descriptionLabel.text = message
      //      arrowImageView.isHidden = false
      //      showRouteButton.isUserInteractionEnabled = true
      //      let speechUtterance = AVSpeechUtterance(string: message)
      //      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
      //      speechUtterance.rate = 0.5
      //      speechSynthesizer.usesApplicationAudioSession = false
      //      speechSynthesizer.speak(speechUtterance)
      //      stepCounter = 0
      //      navigationStarted.value = false
      //      for monitoredRegion in locationManager.monitoredRegions {
      //        locationManager.stopMonitoring(for: monitoredRegion)
      //      }
    }
  }
}

//MARK: - UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
  
  private func configureDropPinAndPolyline() {
    let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                         action: #selector(handleTap)
    )
    gestureRecognizer.delegate = self
    mapView.addGestureRecognizer(gestureRecognizer)
  }
  
  @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      let location = gestureRecognizer.location(in: mapView)
      let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
      
      // Show Address
      getUserAddress(lattitude: coordinate.latitude,
                     longitude: coordinate.longitude
      )
      
      // Add annotation
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      mapView.addAnnotation(annotation)
      
      resetButton(annotation: annotation)
      if !mapView.annotations.isEmpty {
        self.button.backgroundColor = .systemRed
        self.button.isUserInteractionEnabled = true
      }
      
      // Add polyline
      if feature.value == .polyline {
        coordinates.value.append(coordinate)
        let polyline = MKPolyline(coordinates: coordinates.value,
                                  count: coordinates.value.count
        )
        mapView?.addOverlay(polyline)
      }
      isSelected.value = false
    }
  }
}

//MARK: - Routing Method

extension MapViewController {
  
  private func routeToSearchController() {
    //    let searchController = StoryBoardScene.Main.instantiateViewController(withClass: SearchController.self)
    let searchController: SearchController = SearchController()
    configureSearchController(searchController: searchController)
    push(searchController)
  }
  
  private func routeToRoutesController() {
    let routesController = StoryBoardScene.Main.instantiateViewController(withClass: RoutesController.self)
    print(steps)
    routesController.steps = steps
    push(routesController)
  }
}
