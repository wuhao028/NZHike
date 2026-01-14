//
//  LocationMapView.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI
import MapKit

struct LocationMapView: View {
    let easting: Double
    let northing: Double
    let title: String
    
    @State private var region: MKCoordinateRegion
    private let coordinate: CLLocationCoordinate2D
    
    init(easting: Double, northing: Double, title: String) {
        self.easting = easting
        self.northing = northing
        self.title = title
        
        let coord = CoordinateConverter.nztmToWgs84(easting: easting, northing: northing)
        self.coordinate = coord
        _region = State(initialValue: MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        Map(initialPosition: .region(region)) {
            Marker(title, coordinate: coordinate)
                .tint(.green)
            UserAnnotation()
        }
        .frame(height: 200)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    LocationMapView(easting: 1464880, northing: 5171064, title: "Woolshed Creek Hut")
}
