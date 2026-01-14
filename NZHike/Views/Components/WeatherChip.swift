//
//  WeatherChip.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI

struct WeatherChip: View {
    let weather: WeatherInfo
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: weather.condition.icon)
                .font(.caption2)
                .symbolRenderingMode(.multicolor)
            
            Text("\(weather.temperature)°")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(BlurView(style: .systemUltraThinMaterial))
        .cornerRadius(12)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
