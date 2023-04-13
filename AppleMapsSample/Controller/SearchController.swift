//
//  SearchController.swift
//  AppleMapsSample
//
//  Created by Lucky on 25/03/23.
//

import UIKit
import MapKit
import Combine

class SearchController: UIViewController {
  
  // MARK: - Public Properties
  
  var closure: ((String?, CLLocationCoordinate2D?) ->())?
  
  // MARK: - Private Properties
  
  private var searchSource = CurrentValueSubject<[String], Never>([])
  private var searchCompleter = MKLocalSearchCompleter()
  private var cancellable = Set<AnyCancellable>()
  
  private var tableView = UITableView()
  private var containerView = UIView()
  private var searchTextField = UITextField()
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetUp()
  }
}

//MARK: - Private Method

extension SearchController {
  
  private func initialSetUp() {
    searchCompleter.delegate = self
    configureNavigation()
    configureContainerView()
    configuretextField()
    configureTableView()
    bind()
    view.backgroundColor = .white
  }
  
  private func configureTableView() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.contentInset.bottom = 20
  }
  
  private func autoComplete() {
    guard let text = searchTextField.text else {
      return
    }
    if text.isEmpty {
      searchSource.value.removeAll()
    } else {
      searchCompleter.queryFragment = text
    }
  }
  
  private func tableCell(cell: UITableViewCell, address: String) {
    var content = cell.defaultContentConfiguration()
    content.text = address
    cell.contentConfiguration = content
    cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    cell.selectionStyle = .none
  }
  
  private func configureContainerView() {
    view.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    containerView.layer.borderWidth = 1
    containerView.layer.borderColor = UIColor.gray.cgColor
    containerView.layer.cornerRadius = 10
  }
  
  private func configuretextField() {
    containerView.addSubview(searchTextField)
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
    searchTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    searchTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    searchTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
    searchTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
    
    searchTextField.becomeFirstResponder()
    searchTextField.delegate = self
    searchTextField.clearButtonMode = .whileEditing
    searchTextField.returnKeyType = .done
  }
  
  private func configureNavigation() {
    title = "Search Address"
  }
}

//MARK: - Bind Method

extension SearchController {
  
  private func bind() {
    bindButton()
    bindElements()
  }
  
  private func bindButton() {
    searchTextField
      .textPublisher
      .sink(receiveValue: { [weak self] _ in
        guard let self else {
          return
        }
        self.autoComplete()
      })
      .store(in: &cancellable)
  }
  
  private func bindElements() {
    searchSource
      .sink(receiveValue: { [weak self] _ in
        guard let self else {
          return
        }
        self.tableView.reloadData()
      })
      .store(in: &cancellable)
  }
}

//MARK: - UITableViewDataSource

extension SearchController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchSource.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let address = searchSource.value[indexPath.row]
    tableCell(cell: cell, address: address)
    return cell
  }
}

//MARK: - MKLocalSearchCompleterDelegate

extension SearchController: MKLocalSearchCompleterDelegate {
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    self.searchSource.value = completer.results.map { $0.title }
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print(error.localizedDescription)
  }
}

//MARK: - UITableViewDelegate

extension SearchController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let address = searchSource.value[indexPath.row]
    
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = address
    let search = MKLocalSearch(request: searchRequest)
    
    search.start { (response, error) in
      if error == nil {
        let coordinate = response?.mapItems.first?.placemark.coordinate
        self.closure?(address, coordinate)
        print(address, coordinate)
      }
    }
    self.navigationController?.popViewController(animated: true)
  }
}

//MARK: - Private Method

extension SearchController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
