import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedTab = 0
    
    // Services
    private let trackService: TrackService
    private let hutService: HutService
    private let campsiteService: CampsiteService
    private let favoritesManager: FavoritesManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(trackService: TrackService, hutService: HutService, campsiteService: CampsiteService, favoritesManager: FavoritesManager) {
        self.trackService = trackService
        self.hutService = hutService
        self.campsiteService = campsiteService
        self.favoritesManager = favoritesManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Observe FavoritesManager changes to trigger UI refresh for heart buttons
        Publishers.CombineLatest3(
            favoritesManager.$favoriteTrackIds,
            favoritesManager.$favoriteHutIds,
            favoritesManager.$favoriteCampsiteIds
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _, _, _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    var filteredTracks: [Track] {
        trackService.searchTracks(query: searchText)
    }
    
    var filteredHuts: [Hut] {
        hutService.searchHuts(query: searchText)
    }
    
    var filteredCampsites: [Campsite] {
        campsiteService.searchCampsites(query: searchText)
    }
    
    func isFavorite(track: Track) -> Bool {
        favoritesManager.isFavorite(trackId: track.id)
    }
    
    func isFavorite(hut: Hut) -> Bool {
        favoritesManager.isFavorite(hutId: hut.id)
    }
    
    func isFavorite(campsite: Campsite) -> Bool {
        favoritesManager.isFavorite(campsiteId: campsite.id)
    }
    
    func toggleFavorite(track: Track) {
        favoritesManager.toggleFavorite(track: track)
    }
    
    func toggleFavorite(hut: Hut) {
        favoritesManager.toggleFavorite(hut: hut)
    }
    
    func toggleFavorite(campsite: Campsite) {
        favoritesManager.toggleFavorite(campsite: campsite)
    }
}
