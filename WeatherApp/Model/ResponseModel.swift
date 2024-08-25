//
//  ResponseModel.swift
//  WeatherApp
//
//  
//

import Foundation
import WeatherKit
struct ResponseModelData: Codable{
    var queryCost: Double?
    var latitude, longitude: Double?
    var resolvedAddress, address, timezone: String?
    var tzoffset: Double?
    var description: String?
    var days: [CurrentConditions]?
    var stations: [String: Station]?
    var currentConditions: CurrentConditions?
}

// MARK: - CurrentConditions
struct CurrentConditions: Codable {
    var datetime: String?
    var datetimeEpoch: Double?
    var temp, feelslike, humidity, dew: Double?
    var precip, precipprob: Double?
    var snow, snowdepth: Double?
    var preciptype: [String]?
    var windgust: Double?
    var windspeed, winddir, pressure, visibility: Double?
    var cloudcover, solarradiation, solarenergy: Double?
    var uvindex: Double?
    var conditions: Conditions?
    var icon: String?
    var stations: [String]?
    var source: Source?
    var sunrise: String?
    var sunriseEpoch: Double?
    var sunset: String?
    var sunsetEpoch: Double?
    var moonphase, tempmax, tempmin, feelslikemax: Double?
    var feelslikemin, precipcover: Double?
    var severerisk: Double?
    var description: String?
    var hours: [CurrentConditions]?
}

enum Conditions: String, Codable {
    case clear = "Clear"
    case overcast = "Overcast"
    case partiallyCloudy = "Partially cloudy"
    case rainOvercast = "Rain, Overcast"
    case snowOvercast = "Snow, Overcast"
    case rainPartiallyCloudy = "Rain, Partially cloudy"
    case snowPartiallyCloudy = "Snow, Partially cloudy"
    case snowRainPartiallyCloudy = "Snow, Rain, Partially cloudy"
    case snowRainOvercast = "Snow, Rain, Overcast"
    case rain = "Rain"
    case snowy = "Snow"
    case storm = "Storm"
    case windy = "Windy"
    case dry = "Dry"
    case fog = "Fog"
    case haze = "Haze"
}

enum Icon: String, Codable {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case rain = "rain"
}

enum Source: String, Codable {
    case comb = "comb"
    case fcst = "fcst"
    case obs = "obs"
}



// MARK: - Station
struct Station: Codable {
    var distance: Double?
    var latitude, longitude: Double?
    var useCount: Double?
    var id: String?
    var name: String?
    var quality, contribution: Double?
}
