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
            VStack(alignment: .leading, spacing: 0) {
                WeatherHeaderView(weather: weather, title: "Weather Forecast")
                
                HStack(spacing: 12) {
                    WeatherDetailIcon(icon: "thermometer.sun", value: "\(weather.high)°", label: "High")
                    WeatherDetailIcon(icon: "thermometer.snowflake", value: "\(weather.low)°", label: "Low")
                    WeatherDetailIcon(icon: "drop.fill", value: "\(weather.humidity)%", label: "Humidity")
                    WeatherDetailIcon(icon: "wind", value: "\(Int(weather.windSpeed)) km/h", label: "Wind")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
        .padding(.horizontal)
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
