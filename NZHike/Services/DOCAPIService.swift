//
//  DOCAPIService.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

@MainActor
class DOCAPIService: ObservableObject {
    @Published var trackDetail: TrackDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.doc.govt.nz/v1/tracks"
    
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["DOC_API_KEY"] as? String else {
            fatalError("DOC_API_KEY not found in APIKeys.plist")
        }
        return key
    }
    
    func fetchTrackDetail(assetId: String) async {
        isLoading = true
        errorMessage = nil
        
        var urlComponents = URLComponents(string: "\(baseURL)/\(assetId)/detail")
        urlComponents?.queryItems = [
            URLQueryItem(name: "doc.api.key", value: apiKey)
        ]
        
        guard let url = urlComponents?.url else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let statusCode = httpResponse.statusCode
                if let errorData = String(data: data, encoding: .utf8) {
                    errorMessage = "API request failed (Status: \(statusCode)): \(errorData)"
                } else {
                    errorMessage = "API request failed with status code: \(statusCode)"
                }
                isLoading = false
                return
            }
            
            // Debug: print response data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            trackDetail = try decoder.decode(TrackDetail.self, from: data)
            isLoading = false
        } catch let decodingError as DecodingError {
            var errorDescription = "Failed to decode API response: "
            switch decodingError {
            case .keyNotFound(let key, let context):
                errorDescription += "Key '\(key.stringValue)' not found. \(context.debugDescription)"
            case .typeMismatch(let type, let context):
                errorDescription += "Type mismatch for type \(type). \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorDescription += "Value not found for type \(type). \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorDescription += "Data corrupted. \(context.debugDescription)"
            @unknown default:
                errorDescription += "Unknown decoding error"
            }
            errorMessage = errorDescription
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
