//
//  WeatherType.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 23.02.2021.
//

import Foundation

enum LastRequestType: Int, Codable {
    case id = 0
    case location = 1
}

protocol WeatherType {
    var type: LastRequestType { get set }
}

struct CoordWeather: WeatherType, Codable {
    var type: LastRequestType
    
    var lat: Double
    var long: Double
}

struct IdWeather: WeatherType, Codable {
    var type: LastRequestType
    var id: Int
}
