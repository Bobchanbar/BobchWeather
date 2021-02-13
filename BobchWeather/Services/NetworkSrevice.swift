//
//  NetworkSrevice.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 13.02.2021.
//

import Foundation

protocol WeatherAPI: class {
    func getWeatherByCityId(_ id: Int, complition: @escaping (Result<NRootWeatherModel,
            BobchNetworkError>) -> Void)
    func getWeatherByCoordinats(_ lat: Double, _ long: Double, complition: @escaping
            (Result<NRootWeatherModel, BobchNetworkError>) -> Void)
}

enum BobchNetworkError: Error {
    case URLNilError
    case URLDomainError(NSError)
    case URLBadResponce(Int)
    case URLDataNilError
    case DecodeError
}

class NetworkService: WeatherAPI {
    func getWeatherByCoordinats(_ lat: Double, _ long: Double, complition: @escaping (Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(long)"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        createRequest(queryItems: queryItems, complition: complition)
    }
    
    func getWeatherByCityId(_ id: Int, complition: @escaping (Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "id", value: "\(id)"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        createRequest(queryItems: queryItems, complition: complition)
    }
    
    static let shared: WeatherAPI = NetworkService()
    
    private let apiKey = "aca00d0db160f87cc5ff7c58b103d3da"
    
    
    func createRequest(queryItems: [URLQueryItem], complition: @escaping(Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            complition(.failure(.URLNilError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            if let error = error as NSError? {
                complition(.failure(.URLDomainError(error)))
                return
            }
            
            guard let resp = responce as? HTTPURLResponse else {
                complition(.failure(.URLBadResponce(-1)))
                return
            }
            
            guard(200...301).contains(resp.statusCode) else {
                complition(.failure(.URLBadResponce(resp.statusCode)))
                return
            }
            
            guard let data = data else {
                complition(.failure(.URLDataNilError))
                return
            }
            
            do {
                let weatherResult = try JSONDecoder().decode(NRootWeatherModel.self, from: data)
                complition(.success(weatherResult))
            } catch {
                complition(.failure(.DecodeError))
            }
        }.resume()
            
    }
    
    
}
