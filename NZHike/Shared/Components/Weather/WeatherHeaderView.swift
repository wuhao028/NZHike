//
//  WeatherHeaderView.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI

struct WeatherHeaderView: View {
    let weather: WeatherInfo
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    init(weather: WeatherInfo = WeatherService.shared.getCurrentWeather(), title: String = "Today's Weather") {
        self.weather = weather
        self.title = title
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                HStack(alignment: .bottom, spacing: 12) {
                    Text("\(weather.temperature)°")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(weather.condition.rawValue)
                            .font(.headline)
                        Text("H: \(weather.high)° L: \(weather.low)°")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(weather.condition.color.opacity(colorScheme == .dark ? 0.3 : 0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: weather.condition.icon)
                    .font(.system(size: 44))
                    .symbolRenderingMode(.multicolor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct WeatherHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHeaderView()
            .previewLayout(.sizeThatFits)
    }
}
