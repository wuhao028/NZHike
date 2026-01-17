import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
class TrackDetailViewModel: ObservableObject {
    let trackId: String
    
    @Published var track: Track?
    @Published var trackDetail: TrackDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: DOCAPIService
    private let trackService: TrackService
    private let favoritesManager: FavoritesManager
    private var cancellables = Set<AnyCancellable>()
    
    init(trackId: String, apiService: DOCAPIService, trackService: TrackService, favoritesManager: FavoritesManager) {
        self.trackId = trackId
        self.apiService = apiService
        self.trackService = trackService
        self.favoritesManager = favoritesManager
        
        loadInitialData()
        setupBindings()
    }
    
    private func loadInitialData() {
        self.track = trackService.allTracks.first(where: { $0.id == trackId }) ??
                    trackService.recommendedTracks.first(where: { $0.id == trackId }) ??
                    favoritesManager.favoriteTracks.first(where: { $0.id == trackId })
    }
    
    private func setupBindings() {
        apiService.$trackDetail
            .assign(to: &$trackDetail)
        apiService.$isLoading
            .assign(to: &$isLoading)
        apiService.$errorMessage
            .assign(to: &$errorMessage)
            
        // Observe FavoritesManager changes
        favoritesManager.$favoriteTrackIds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func fetchDetails() async {
        if trackDetail == nil {
            await apiService.fetchTrackDetail(assetId: trackId)
        }
    }
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(trackId: trackId)
    }
    
    func toggleFavorite() {
        if let track = track {
            favoritesManager.toggleFavorite(track: track)
        }
    }
    
    // Coordinate logic
    var mapX: Double? {
        (track?.x ?? 0) != 0 ? track?.x : ((trackDetail?.x ?? 0) != 0 ? trackDetail?.x : nil)
    }
    
    var mapY: Double? {
        (track?.y ?? 0) != 0 ? track?.y : ((trackDetail?.y ?? 0) != 0 ? trackDetail?.y : nil)
    }
    
    var mapTitle: String {
        track?.name ?? trackDetail?.name ?? "Location"
    }
}
