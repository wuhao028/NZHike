//
//  StatusBadge.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.1))
            .foregroundColor(backgroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        let lStatus = status.lowercased()
        if lStatus.contains("open") {
            return .green
        } else if lStatus.contains("closed") || lStatus.contains("restricted") {
            return .red
        } else if lStatus.contains("warning") || lStatus.contains("alert") {
            return .orange
        } else {
            return .blue
        }
    }
}
