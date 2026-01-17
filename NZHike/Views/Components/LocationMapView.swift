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
    
    private var coordinate: CLLocationCoordinate2D {
        // NZTM easting is usually > 1M, northing > 4M
        if easting > 1000000 && northing > 4000000 {
            return CoordinateConverter.nztmToWgs84(easting: easting, northing: northing)
        } else {
            // Assume already WGS84 (northing is lat, easting is lon)
            return CLLocationCoordinate2D(latitude: northing, longitude: easting)
        }
    }
    
    var body: some View {
        Map(position: .constant(.region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))) {
            Marker(title, coordinate: coordinate)
                .tint(.green)
            UserAnnotation()
        }
        .frame(height: 200)
        .cornerRadius(12)
        .shadow(radius: 2)
        .id("\(coordinate.latitude)-\(coordinate.longitude)")
    }
}

#Preview {
    LocationMapView(easting: 1464880, northing: 5171064, title: "Woolshed Creek Hut")
}
