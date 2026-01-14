//
//  WeatherSectionView.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI

struct WeatherSectionView: View {
    let region: String?
    
    var body: some View {
        let weather = WeatherService.shared.getWeather(for: region)
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Forecast")
                .font(.title3)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: weather.condition.icon)
                        .font(.system(size: 40))
                        .symbolRenderingMode(.multicolor)
                    
                    Text(weather.condition.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(weather.temperature)°")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        Text("C")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                    
                    HStack(spacing: 12) {
                        WeatherDetailIcon(icon: "thermometer.sun", value: "\(weather.high)°", label: "High")
                        WeatherDetailIcon(icon: "thermometer.snowflake", value: "\(weather.low)°", label: "Low")
                        WeatherDetailIcon(icon: "drop.fill", value: "\(weather.humidity)%", label: "Humidity")
                        WeatherDetailIcon(icon: "wind", value: "\(Int(weather.windSpeed)) km/h", label: "Wind")
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

struct WeatherDetailIcon: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.accentColor)
            Text(value)
                .font(.system(size: 10, weight: .bold))
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}
