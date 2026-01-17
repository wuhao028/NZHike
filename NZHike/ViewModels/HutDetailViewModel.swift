import Foundation
import SwiftUI
import Combine

@MainActor
class HutDetailViewModel: ObservableObject {
    let hut: Hut
    
    @Published var hutDetail: HutDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: DOCAPIService
    private let favoritesManager: FavoritesManager
    private var cancellables = Set<AnyCancellable>()
    
    init(hut: Hut, apiService: DOCAPIService, favoritesManager: FavoritesManager) {
        self.hut = hut
        self.apiService = apiService
        self.favoritesManager = favoritesManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        apiService.$hutDetail
            .assign(to: &$hutDetail)
        apiService.$isLoading
            .assign(to: &$isLoading)
        apiService.$errorMessage
            .assign(to: &$errorMessage)
            
        // Observe FavoritesManager changes
        favoritesManager.$favoriteHutIds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func fetchDetails() async {
        await apiService.fetchHutDetail(assetId: String(hut.assetId))
    }
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(hutId: hut.id)
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(hut: hut)
    }
}
