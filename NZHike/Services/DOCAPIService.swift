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
    
    private let tracksBaseURL = "https://api.doc.govt.nz/v1/tracks"
    private let hutsBaseURL = "https://api.doc.govt.nz/v2/huts"
    
    @Published var hutDetail: HutDetail?
    @Published var campsiteDetail: CampsiteDetail?
    
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["DOC_API_KEY"] as? String else {
            fatalError("DOC_API_KEY not found in APIKeys.plist")
        }
        return key
    }
    
    func fetchTrackDetail(assetId: String) async {
        await fetchData(endpoint: "\(tracksBaseURL)/\(assetId)/detail", target: \.trackDetail)
    }
    
    func fetchHutDetail(assetId: String) async {
        await fetchData(endpoint: "\(hutsBaseURL)/\(assetId)/detail", target: \.hutDetail)
    }
    
    func fetchCampsiteDetail(assetId: String) async {
        await fetchData(endpoint: "https://api.doc.govt.nz/v2/campsites/\(assetId)/detail", target: \.campsiteDetail)
    }
    
    private func fetchData<T: Decodable>(endpoint: String, target: ReferenceWritableKeyPath<DOCAPIService, T?>) async {
        isLoading = true
        errorMessage = nil
        
        var urlComponents = URLComponents(string: endpoint)
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
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(T.self, from: data)
            
            // Assign to the published property
            // Since we are in an async context but referencing self (Actor/MainActor), we need to be careful.
            // However, common pattern with published properties in ObservableObject is straight assignment if on MainActor.
            // The method is async, but the class is @MainActor.
            self[keyPath: target] = decodedData
            isLoading = false
            
        } catch {
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
