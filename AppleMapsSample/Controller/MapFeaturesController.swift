//
//  MapFeaturesController.swift
//  AppleMapsSample
//
//  Created by Lucky on 22/03/23.
//

import UIKit
import SwiftUI

class MapFeaturesController: UIViewController {
  
  // MARK: - Private Properties
  
  private var tableView: UITableView = UITableView()
  
  var features: [Features] = [
    .polygon,
    .pin,
    .polyline,
    .route,
    .custom,
    .flyOver,
    .lookAround
  ]
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension MapFeaturesController {
  
  private func initialSetup() {
    view.backgroundColor = .white
    configureTableView()
    configureNavigation()
  }
  
  private func configureTableView() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.contentInset.bottom = 20
  }
  
  private func configureNavigation() {
    title = "Features"
  }
  
  private func tableCell(cell: UITableViewCell, feature: Features) {
    var content = cell.defaultContentConfiguration()
    if feature == .custom {
      content.image = UIImage(named: feature.icon)
    } else {
      content.image = UIImage(systemName: feature.icon)
    }
    content.text = feature.title
    cell.tintColor = feature.iconColor
    cell.contentConfiguration = content
    cell.accessoryType = .disclosureIndicator
    cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    cell.selectionStyle = .none
  }
  
  private func configureAlert() {
    let alert = UIAlertController(title: "Map Types", message: "Device does not support this feature", preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default)
    alert.addAction(action)
    present(alert, animated: true)
  }
}

//MARK: - UITableViewDataSource

extension MapFeaturesController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return features.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let feature = features[indexPath.row]
    tableCell(cell: cell, feature: feature)
    return cell
  }
}

//MARK: - UITableViewDelegate

extension MapFeaturesController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let feature = features[indexPath.row]
    switch feature {
    case .polygon:
      routePolygonController(feature: feature)
      
    case .flyOver:
      routeToFlyController(feature: feature)
      
    case .lookAround:
      routeToLookAroundController()
      
    case .pin:
      routeToDropPinController(feature: feature)
      
    case .polyline:
      routeToPolylineController(feature: feature)
      
    case .custom:
      routeToCustomController(feature: feature)
      
    case .route:
      routeDirectionController(feature: feature)
      
    default:
      routeDirectionController(feature: feature)
    }
  }
}

//MARK: - Routing Method

extension MapFeaturesController {
  
  private func routeToFlyController(feature: Features) {
    let flyController: FlyOverController = FlyOverController()
    flyController.feature.value = feature
    push(flyController)
  }
  
  private func routeToLookAroundController() {
    if #available(iOS 16.0, *) {
      let lookAroudVc = UIHostingController(rootView: LocationScreen())
      push(lookAroudVc)
    } else {
      configureAlert()
      print("Not Supported")
    }
  }
  
  private func routeToDropPinController(feature: Features) {
    let dropPinController: DropPinController = DropPinController()
    dropPinController.feature.value = feature
    push(dropPinController)
  }
  
  private func routeToPolylineController(feature: Features) {
    let polylineController: PolylineController = PolylineController()
    polylineController.feature.value = feature
    push(polylineController)
  }
  
  private func routeToCustomController(feature: Features) {
    let customController: CustomAnnotationController = CustomAnnotationController()
    customController.feature.value = feature
    push(customController)
  }
  
  private func routeDirectionController(feature: Features) {
    let routeDirectionController: RouteDirectionController = RouteDirectionController()
    routeDirectionController.feature.value = feature
    push(routeDirectionController)
  }
  
  private func routePolygonController(feature: Features) {
    let routePolygonController: PolygonController = PolygonController()
    routePolygonController.feature.value = feature
    push(routePolygonController)
  }
}
