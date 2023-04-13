//
//  ViewController.swift
//  AppleMapsSample
//
//  Created by Sadanand Lowanshi on 21/03/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  // MARK:- IBOutlets
  
  @IBOutlet var mapView: MKMapView!
  
  var locationManager: CLLocationManager?
  
  // MARK:- LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
  
  private func initialSetup() {
    configureMap()
    configureLocationManager()
    
    if let data = loadMultiPolygonJSON() {
      renderPolygon(coordinates: data.coordinates)
    }
    
    if let data = loadTraceJSON() {
      renderRoutes(routes: data.routes)
    }
  }
  
  private func configureMap() {
    mapView.delegate = self
  }
  
  func configureLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.startUpdatingLocation()
  }
}

// MARK:- Private Methods

extension ViewController {
  
  private func loadMultiPolygonJSON() -> PolygonResponseData? {
    guard let url = Bundle.main.url(forResource: "geojson_response", withExtension: "json") else {
      return nil
    }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let jsonData = try decoder.decode(PolygonResponseData.self, from: data)
      return jsonData
    } catch {
      print("error:\(error)")
      return nil
    }
  }
  
  private func loadTraceJSON() -> TraceResponseData? {
    guard let url = Bundle.main.url(forResource: "trace", withExtension: "json") else {
      return nil
    }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let jsonData = try decoder.decode(TraceResponseData.self, from: data)
      return jsonData
    } catch {
      print("error:\(error)")
      return nil
    }
  }
  
  private func renderPolygon(coordinates: [[[[Double]]]]) {
    coordinates.forEach { coordinate in
      if let first = coordinate.first {
        let coordinateInput = first.compactMap { value in
          return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
        }
        drawPolygon(coordinateInput)
      }
    }
  }
  
  private func renderRoutes(routes: [[Point]]) {
    if let route = routes.first {
      route.forEach { point in
        addPin(at: point.location.coordinate)
      }
      
      if route.count > 50 {
        let firstFiftyPoints = route.enumerated().compactMap { $0.offset <= 50 ? $0.element.location : nil }
        let remainingPoints = route.enumerated().compactMap { $0.offset > 50 ? $0.element.location.coordinate : nil }
        
        fetchDirections(firstFiftyPoints) { coordinates in
          self.drawRoute(locations: coordinates)
        }
        
        drawRoute(locations: remainingPoints)
        
      } else {
        fetchDirections(route.map({ $0.location })) { coordinates in
          self.drawRoute(locations: coordinates)
        }
      }
    }
  }
  
  private func addPin(at coordinate: CLLocationCoordinate2D) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
  }
  
  private func drawPolygon(_ coordinateInput: [CLLocationCoordinate2D]) {
    let line = MKPolygon(coordinates: coordinateInput, count: coordinateInput.count)
    mapView.addOverlay(line)
  }
  
  private func drawRoute(locations: [CLLocationCoordinate2D]) {
    let polyline = MKPolyline(coordinates: locations, count: locations.count)
    mapView.addOverlay(polyline, level: .aboveRoads)
  }
}

// MARK:- MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polygonOverlay = overlay as? MKPolygon {
      let renderer = MKPolygonRenderer(polygon: polygonOverlay)
      renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
      renderer.strokeColor = UIColor.orange
      renderer.lineWidth = 4
      return renderer
    } else if let polyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(polyline: polyline)
      renderer.strokeColor = .blue
      renderer.fillColor = .blue
      renderer.lineWidth = 4
      renderer.lineCap = .round
      return renderer
    } else {
      return MKOverlayRenderer()
    }
  }
}

// MARK:- MKMapViewDelegate

extension ViewController {
  
  func fetchDirections(_ locations: [CLLocation], completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
    let pointCount = locations.count
    
    guard pointCount > 1 else { return }
    
    var routes: [[CLLocationCoordinate2D]?] = Array(repeating: nil, count: pointCount - 1)
    let group = DispatchGroup()
    
    for i in 1 ..< pointCount {
      group.enter()
      directions(from: locations[i-1], to: locations[i]).calculate { response, error in
        defer { group.leave() }
        
        guard
          error == nil,
          let response = response,
          let route = response.routes.first
        else { return }
        
        routes[i-1] = self.coordinates(for: route.steps)
      }
    }
    
    group.notify(queue: .main) {
      let coordinates = routes.compactMap { $0 }.flatMap { $0 }
      completion(coordinates)
    }
  }
  
  func directions(from: CLLocation, to: CLLocation) -> MKDirections {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: from.coordinate))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to.coordinate))
    request.requestsAlternateRoutes = false
    request.transportType = .automobile
    return MKDirections(request: request)
  }
  
  func coordinates(for steps: [MKRoute.Step]) -> [CLLocationCoordinate2D] {
    guard !steps.isEmpty else { return [] }
    
    var coordinates: [CLLocationCoordinate2D] = []
    
    for step in steps {
      let count = step.polyline.pointCount
      let pointer = step.polyline.points()
      for i in 0 ..< count {
        let coordinate = pointer[i].coordinate
        if coordinate.latitude != coordinates.last?.latitude, coordinate.longitude != coordinates.last?.longitude {
          coordinates.append(coordinate)
        }
      }
    }
    return coordinates
  }
}

// MARK:- CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
      self.mapView.setRegion(region, animated: true)
    }
  }
}
