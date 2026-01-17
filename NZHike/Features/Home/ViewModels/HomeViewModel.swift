import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var selectedTab = 0
    
    // Services
    private let trackService: TrackService
    private let hutService: HutService
    private let campsiteService: CampsiteService
    private let favoritesManager: FavoritesManager
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var recommendedTracks: [Track] = []
    @Published var recommendedHuts: [Hut] = []
    @Published var recommendedCampsites: [Campsite] = []
    
    @Published var isTracksLoading = false
    @Published var isHutsLoading = false
    @Published var isCampsitesLoading = false
    
    @Published var tracksErrorMessage: String?
    @Published var hutsErrorMessage: String?
    @Published var campsitesErrorMessage: String?
    
    init(trackService: TrackService, hutService: HutService, campsiteService: CampsiteService, favoritesManager: FavoritesManager) {
        self.trackService = trackService
        self.hutService = hutService
        self.campsiteService = campsiteService
        self.favoritesManager = favoritesManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind TrackService
        trackService.$recommendedTracks
            .assign(to: &$recommendedTracks)
        trackService.$isLoading
            .assign(to: &$isTracksLoading)
        trackService.$errorMessage
            .assign(to: &$tracksErrorMessage)
            
        // Bind HutService
        hutService.$recommendedHuts
            .assign(to: &$recommendedHuts)
        hutService.$isLoading
            .assign(to: &$isHutsLoading)
        hutService.$errorMessage
            .assign(to: &$hutsErrorMessage)
            
        // Bind CampsiteService
        campsiteService.$recommendedCampsites
            .assign(to: &$recommendedCampsites)
        campsiteService.$isLoading
            .assign(to: &$isCampsitesLoading)
        campsiteService.$errorMessage
            .assign(to: &$campsitesErrorMessage)
            
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
