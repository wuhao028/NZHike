import Foundation
import SwiftUI
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var selectedCategory: FavoriteCategory = .all
    @Published var showMapView = false
    
    // Services
    private let favoritesManager: FavoritesManager
    
    @Published var favoriteTracks: [Track] = []
    @Published var favoriteHuts: [Hut] = []
    @Published var favoriteCampsites: [Campsite] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
        setupBindings()
    }
    
    private func setupBindings() {
        favoritesManager.$favoriteTracks
            .assign(to: &$favoriteTracks)
        favoritesManager.$favoriteHuts
            .assign(to: &$favoriteHuts)
        favoritesManager.$favoriteCampsites
            .assign(to: &$favoriteCampsites)
    }
    
    var hasFavorites: Bool {
        !favoriteTracks.isEmpty || !favoriteHuts.isEmpty || !favoriteCampsites.isEmpty
    }
    
    func shouldShow(_ category: FavoriteCategory) -> Bool {
        selectedCategory == .all || selectedCategory == category
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
    
    func refresh() {
        favoritesManager.loadFavorites()
    }
}
