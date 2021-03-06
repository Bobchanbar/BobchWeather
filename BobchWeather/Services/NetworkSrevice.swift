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

protocol CityIDAPI: class {
    func getCitiesByName(_ name: String, complition: @escaping (Result<[NCityModel], BobchNetworkError>)->Void)
}

enum BobchNetworkError: Error {
    case URLNilError
    case URLDomainError(NSError)
    case URLBadResponce(Int)
    case URLDataNilError
    case DecodeError
}

class NetworkService {
    
    static let shared: WeatherAPI & CityIDAPI = NetworkService()
    
    private let apiKey = "aca00d0db160f87cc5ff7c58b103d3da"
    
    
    func createRequest(urlComponents: URLComponents, complition: @escaping(Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        
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
    func createRequest(urlComponents: URLComponents, complition: @escaping(Result<[NCityModel], BobchNetworkError>) -> Void) {
        
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
                let citiesResult = try JSONDecoder().decode([NCityModel].self, from: data)
                complition(.success(citiesResult))
            } catch {
                complition(.failure(.DecodeError))
            }
        }.resume()
            
    }
    
}



// MARK: - WeatherApi

extension NetworkService: WeatherAPI {
    func getWeatherByCoordinats(_ lat: Double, _ long: Double, complition: @escaping (Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(long)"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        createRequest(urlComponents: urlComponents, complition: complition)
    }
    
    func getWeatherByCityId(_ id: Int, complition: @escaping (Result<NRootWeatherModel, BobchNetworkError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: "\(id)"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        createRequest(urlComponents: urlComponents, complition: complition)
    }
}

extension NetworkService: CityIDAPI {
    func getCitiesByName(_ name: String, complition: @escaping (Result<[NCityModel], BobchNetworkError>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "kavars.com"
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]
        
        createRequest(urlComponents: urlComponents, complition: complition)
    }
}
