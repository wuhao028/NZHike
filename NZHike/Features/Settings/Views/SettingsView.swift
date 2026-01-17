//
//  SettingsView.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    HStack {
                        Image(systemName: "paintpalette")
                            .foregroundColor(.accentColor)
                        Text("Theme")
                        Spacer()
                        Picker("Theme", selection: Binding(
                            get: { appState.currentTheme },
                            set: { appState.setTheme($0) }
                        )) {
                            ForEach(AppState.AppTheme.allCases, id: \.self) { theme in
                                Text(theme.rawValue.capitalized).tag(theme)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}
