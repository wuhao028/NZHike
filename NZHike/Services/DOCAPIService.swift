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
    
    func fetchTrackDetail(docId: String) async {
        isLoading = true
        errorMessage = nil
        
        var urlComponents = URLComponents(string: "\(baseURL)/\(docId)")
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
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "API request failed"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            trackDetail = try decoder.decode(TrackDetail.self, from: data)
            isLoading = false
        } catch {
            errorMessage = "Failed to parse data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
