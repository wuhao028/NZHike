//
//  WeatherService.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import Foundation
import SwiftUI

struct WeatherInfo: Identifiable {
    let id = UUID()
    let temperature: Int
    let condition: WeatherCondition
    let high: Int
    let low: Int
    let humidity: Int
    let windSpeed: Double
    
    enum WeatherCondition: String {
        case sunny = "Sunny"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        case snowy = "Snowy"
        case partlyCloudy = "Partly Cloudy"
        case stormy = "Stormy"
        
        var icon: String {
            switch self {
            case .sunny: return "sun.max.fill"
            case .cloudy: return "cloud.fill"
            case .rainy: return "cloud.rain.fill"
            case .snowy: return "mountain.2.fill"
            case .partlyCloudy: return "cloud.sun.fill"
            case .stormy: return "cloud.bolt.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .sunny: return .orange
            case .cloudy: return .gray
            case .rainy: return .blue
            case .snowy: return .indigo
            case .partlyCloudy: return .yellow
            case .stormy: return .purple
            }
        }
    }
}

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    private let conditions: [WeatherInfo.WeatherCondition] = [.sunny, .partlyCloudy, .cloudy, .rainy]
    
    func getWeather(for region: String?) -> WeatherInfo {
        // Mock weather based on region string seed or just semi-random for demo
        let seed = region?.count ?? 0
        let condition = conditions[seed % conditions.count]
        let temp = 15 + (seed % 10)
        
        return WeatherInfo(
            temperature: temp,
            condition: condition,
            high: temp + 3,
            low: temp - 4,
            humidity: 60 + (seed % 20),
            windSpeed: 5.0 + Double(seed % 15)
        )
    }
    
    func getCurrentWeather() -> WeatherInfo {
        return WeatherInfo(
            temperature: 18,
            condition: .partlyCloudy,
            high: 22,
            low: 12,
            humidity: 65,
            windSpeed: 12.5
        )
    }
}
