//
//  CoordinateConverter.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import Foundation
import CoreLocation

struct CoordinateConverter {
    // NZTM2000 to WGS84 conversion constants
    private static let a = 6378137.0
    private static let f = 1 / 298.257222101
    private static let phizero = 0.0
    private static let lambdazero = 173.0
    private static let Nzero = 10000000.0
    private static let Ezero = 1600000.0
    private static let kzero = 0.9996
    
    /// Converts NZTM (Easting, Northing) to WGS84 (Latitude, Longitude)
    /// Also handles coordinates that are already in WGS84 format.
    static func nztmToWgs84(easting: Double, northing: Double) -> CLLocationCoordinate2D {
        // Heuristic: NZTM coordinates are in the millions. WGS84 for NZ are ~170, -40.
        // If values are small, assume they are already WGS84.
        if abs(easting) < 1000000 || abs(northing) < 1000000 {
            // Note: In WGS84, easting is lon, northing is lat
            return CLLocationCoordinate2D(latitude: northing, longitude: easting)
        }
        
        let b = a * (1 - f)
        let esq = 2 * f - f * f
        let e4 = esq * esq
        let e6 = e4 * esq
        
        let m = (northing - Nzero) / kzero
        
        let n = (a - b) / (a + b)
        let G = a * (1 - n) * (1 - n * n) * (1 + 9/4 * n * n + 225/64 * pow(n, 4)) * (Double.pi / 180.0)
        
        // This G calculation is for a formula that expect phi in degrees.
        // Let's use a more direct one.
        
        let A0 = 1 - (esq / 4) - (3 * e4 / 64) - (5 * e6 / 256)
        let A2 = 0.375 * (esq + (e4 / 4) + (15 * e6 / 128))
        let A4 = 0.05859375 * (e4 + (3 * e6 / 4)) // 15/256
        let A6 = 0.011393229166666666 * e6 // 35/3072
        
        // Iteratively find foot-point latitude
        var phi = m / (a * A0)
        for _ in 0...5 {
            let m_guess = a * (A0 * phi - A2 * sin(2 * phi) + A4 * sin(4 * phi) - A6 * sin(6 * phi))
            phi = phi + (m - m_guess) / (a * A0)
        }
        
        let rho = a * (1 - esq) / pow(1 - esq * sin(phi) * sin(phi), 1.5)
        let nu = a / sqrt(1 - esq * sin(phi) * sin(phi))
        let psi = nu / rho
        let t = tan(phi)
        let Et = easting - Ezero
        
        // Series for latitude
        let t_k_nu_rho = t / (kzero * nu * rho)
        let term1 = t_k_nu_rho * Et * Et / 2.0
        let term2 = (t_k_nu_rho * pow(Et, 4) / 24.0 / pow(kzero, 2) / pow(nu, 2)) * (5 + 3 * t * t + psi - 9 * t * t * psi - 4 * psi * psi)
        let term3 = (t_k_nu_rho * pow(Et, 6) / 720.0 / pow(kzero, 4) / pow(nu, 4)) * (61 + 90 * t * t + 45 * pow(t, 4) + 46 * psi - 252 * t * t * psi - 3 * psi * psi)
        
        let latitude = (phi - term1 + term2 - term3) * 180 / Double.pi
        
        // Series for longitude
        let cos_phi = cos(phi)
        let lterm1 = Et / (kzero * nu * cos_phi)
        let lterm2 = pow(Et, 3) / (6 * pow(kzero, 3) * pow(nu, 3) * cos_phi) * (psi + 2 * t * t)
        let lterm3 = pow(Et, 5) / (120 * pow(kzero, 5) * pow(nu, 5) * cos_phi) * (5 + 28 * t * t + 24 * pow(t, 4) + 6 * psi + 8 * t * t * psi)
        
        let longitude = lambdazero + (lterm1 - lterm2 + lterm3) * 180 / Double.pi
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
