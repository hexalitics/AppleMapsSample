//
//  RoutesController.swift
//  AppleMapsSample
//
//  Created by Lucky on 03/04/23.
//

import UIKit
import MapKit

class RoutesController: UIViewController {
  
  // MARK: - Private Properties
  
  private var tableView: UITableView = UITableView()
  
  // MARK: - Public Properties
  
  var steps: [MKRoute.Step] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

//MARK: - Private Method

extension RoutesController {
  
  private func initialSetup() {
    configureTableView()
    configureNavigation()
  }
  
  private func configureNavigation() {
    title = "Steps"
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
    
    if !steps.isEmpty {
      steps.remove(at: 0)
    }
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.contentInset.bottom = 20
  }
  
  private func tableCell(cell: UITableViewCell, step: MKRoute.Step) {
    var content = cell.defaultContentConfiguration()
    content.text = step.instructions
    let distance = Double(round(step.distance * 10) / 10)
    
    content.secondaryText = String(distance) + " meter"
    cell.contentConfiguration = content
    cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    cell.selectionStyle = .none
  }
}

//MARK: - UITableViewDataSource

extension RoutesController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return steps.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let step = steps[indexPath.row]
    tableCell(cell: cell, step: step)
    return cell
  }
}

//MARK: - UITableViewDelegate

extension RoutesController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
