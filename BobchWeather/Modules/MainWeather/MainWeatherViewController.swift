//
//  MainWeatherViewController.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 13.02.2021.
//

import UIKit

class MainWeatherViewController: UIViewController {
    
    //MARK: - Properties
    
    var locationService: LocationServiceProtocol?
    var lastRequestType: WeatherType? {
        didSet {
            //
        }
    }
    
    //MARK: - UIElements
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34)
        return label
    }()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "location"), for: .normal)
        return button
    }()
    
    //MARK: - Actions
    @objc func openSearchController(){
        let citiesSearchVC = CitySearchViewController()
        navigationController?.pushViewController(citiesSearchVC, animated: true)
    }
    
    @objc func getLocation() {
        locationService?.getLocation()
    }
    
    @objc func updateWeather() {
        guard let lastRequestType = lastRequestType else {
            return
        }
        switch lastRequestType.type {
        case .id:
            guard let idWeatherRequest = lastRequestType as? IdWeather else {
                return
            }
            getWeatherByID(idWeatherRequest.id)
        case .location:
            guard let coordWeatherRequest = lastRequestType as? CoordWeather else {
                return
            }
            getWeatherByLocation(coordWeatherRequest.lat, coordWeatherRequest.long)
        }
    }

    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        buildConstraints()
        locationService = LocationService()
        locationService?.delegate = self
    
        getWeatherByID(524901)
    }
    
    //MARK: - Helpers
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tempLabel)
        view.addSubview(locationButton)
        locationButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        
        
        let barSearchButton  = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),style: .plain, target: self, action: #selector(openSearchController))
        
        navigationItem.leftBarButtonItem = barSearchButton
        
        let barUpdateButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),style: .plain, target: self, action: #selector(updateWeather))
        
        navigationItem.rightBarButtonItem = barUpdateButton
        
    }
    
    func buildConstraints() {
        NSLayoutConstraint.activate([
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            locationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func getWeatherByID(_ ID: Int) {
        lastRequestType = IdWeather(type: .id, id: ID)
        
        NetworkService.shared.getWeatherByCityId(ID) { (result) in
            switch result {
            case .success(let weatherResult):
                let temp = Int(weatherResult.main.temp - 273.15)
                DispatchQueue.main.async {
                    self.tempLabel.text = "\(temp)"
                    self.navigationItem.title = weatherResult.name
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getWeatherByLocation(_ lat: Double, _ long: Double) {
        lastRequestType = CoordWeather(type: .location, lat: lat, long: long)
        NetworkService.shared.getWeatherByCoordinats(lat, long) { (result) in
            switch result {
            case .success(let weatherResult):
                let temp = Int(weatherResult.main.temp - 273.15)
                DispatchQueue.main.async {
                    self.tempLabel.text = "\(temp)"
                    self.navigationItem.title = weatherResult.name
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

//MARK: - Location Service Delegate
extension MainWeatherViewController: LocationServiceDelegate {
    func processingLocation(_ lat: Double, _ long: Double) {
        getWeatherByLocation(lat, long)
    }
    func processingLocationError(_ error: NSError) {
        print(error)
    }
}
    

