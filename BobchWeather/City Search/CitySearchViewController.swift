//
//  CitySearchViewController.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 22.02.2021.
//

import UIKit

class CitySearchViewController: UITableViewController {
    var cities: [NCityModel] = []
    var selectedID: Int?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let searchController = UISearchController()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "City search"
        
        navigationItem.searchController = searchController
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "citiesCell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row].name + " " +
            cities[indexPath.row].country
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
    Int {
            return cities.count
    }
}

extension CitySearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultText = searchController.searchBar.text, resultText.count > 2 else {
            return
        }
        NetworkService.shared.getCitiesByName(resultText) { (result) in
            switch result {
            case.success(let cities):
                self.cities = cities
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
}

extension CitySearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cities = []
        tableView.reloadData()
    }
}

extension CitySearchViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let mainVC = viewController as? MainWeatherViewController, let selectedID = selectedID else {
            return
        }
        mainVC.getWeatherByID(selectedID)
    }
}
