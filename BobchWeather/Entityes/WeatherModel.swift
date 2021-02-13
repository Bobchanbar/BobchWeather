//
//  WeatherModel.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 13.02.2021.
//

import Foundation

struct NRootWeatherModel: Codable {
    var main: NMainWeatherModel

}
struct NMainWeatherModel: Codable {
    var temp: Double
}
