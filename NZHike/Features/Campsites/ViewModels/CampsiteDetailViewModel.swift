import Foundation
import SwiftUI
import Combine

@MainActor
class CampsiteDetailViewModel: ObservableObject {
    let campsite: Campsite
    
    @Published var campsiteDetail: CampsiteDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: DOCAPIService
    private let favoritesManager: FavoritesManager
    private var cancellables = Set<AnyCancellable>()
    
    init(campsite: Campsite, apiService: DOCAPIService, favoritesManager: FavoritesManager) {
        self.campsite = campsite
        self.apiService = apiService
        self.favoritesManager = favoritesManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        apiService.$campsiteDetail
            .assign(to: &$campsiteDetail)
        apiService.$isLoading
            .assign(to: &$isLoading)
        apiService.$errorMessage
            .assign(to: &$errorMessage)
            
        // Observe FavoritesManager changes
        favoritesManager.$favoriteCampsiteIds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func fetchDetails() async {
        await apiService.fetchCampsiteDetail(assetId: String(campsite.assetId))
    }
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(campsiteId: campsite.id)
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(campsite: campsite)
    }
}
