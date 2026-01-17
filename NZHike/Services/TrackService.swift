//
//  TrackService.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData

@MainActor
class TrackService: ObservableObject {
    @Published var allTracks: [Track] = []
    @Published var recommendedTracks: [Track] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistenceController = PersistenceController.shared
    private var recommendedTrackIds: Set<String> = []
    
    init() {
        // Load all tracks from database first (for search functionality and coordinate matching)
        loadTracksFromDatabase()
        // Load recommended tracks from local JSON file
        loadRecommendedTracks()
    }
    
    private func loadRecommendedTracks() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "recommendedTracks", withExtension: "json") else {
            errorMessage = "recommendedTracks.json file not found in bundle"
            isLoading = false
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            errorMessage = "Failed to read recommendedTracks.json data"
            isLoading = false
            return
        }
        
        guard let recommendedTracksData = try? JSONDecoder().decode([RecommendedTrack].self, from: data) else {
            errorMessage = "Failed to decode recommendedTracks.json"
            isLoading = false
            return
        }
        
        // Populate recommended IDs
        self.recommendedTrackIds = Set(recommendedTracksData.compactMap { $0.id })
        
        // Convert RecommendedTrack to Track
        let basicRecommended = recommendedTracksData.map { recommendedTrack in
            var track = Track(
                assetId: recommendedTrack.id,
                name: recommendedTrack.name,
                region: [recommendedTrack.region],
                x: 0,
                y: 0,
                line: []
            )
            track.difficulty = recommendedTrack.difficulty
            track.duration = recommendedTrack.duration
            track.distance = recommendedTrack.distance
            track.description = recommendedTrack.description
            track.docId = recommendedTrack.docId
            return track
        }
        
        // Try to enrich recommended tracks with coordinates if we have them in allTracks
        recommendedTracks = basicRecommended.map { recTrack in
            if let fullTrack = allTracks.first(where: { $0.assetId == recTrack.assetId }) {
                var updated = recTrack
                updated.x = fullTrack.x
                updated.y = fullTrack.y
                return updated
            }
            return recTrack
        }
        
        isLoading = false
    }

    func updateRecommendedTracksCoordinates() {
        recommendedTracks = recommendedTracks.map { recTrack in
            // Try matching by ID first, then by name
            if let fullTrack = allTracks.first(where: { $0.assetId == recTrack.assetId }) ??
                               allTracks.first(where: { $0.name.lowercased() == recTrack.name.lowercased() }) {
                var updated = recTrack
                if updated.x == 0 { updated.x = fullTrack.x }
                if updated.y == 0 { updated.y = fullTrack.y }
                if updated.line.isEmpty { updated.line = fullTrack.line }
                return updated
            }
            return recTrack
        }
        objectWillChange.send()
    }
    
    func loadTracksFromDatabase() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            allTracks = entities.map { Track(from: $0) }
            if allTracks.isEmpty {
                // If database is empty, try loading from JSON
                loadTracksFromJSON()
            }
            // Note: We don't update recommendedTracks here because they come from local JSON
            updateRecommendedTracksCoordinates()
        } catch {
            errorMessage = "Failed to load tracks from database: \(error.localizedDescription)"
            // If database load fails, try JSON
            if allTracks.isEmpty {
                loadTracksFromJSON()
            }
        }
    }
    
    func refreshTracks() {
        loadTracksFromDatabase()
    }
    
    func loadTracksFromJSON() {
        // Try allTracks.json first, then fallback to tracks.json
        let jsonFileName = Bundle.main.url(forResource: "allTracks", withExtension: "json") != nil ? "allTracks" : "tracks"
        
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let tracks = try? JSONDecoder().decode([Track].self, from: data) else {
            errorMessage = "Failed to load tracks from JSON"
            return
        }
        
        let context = persistenceController.container.viewContext
        
        for track in tracks {
            // Check if track already exists
            let request: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
            request.predicate = NSPredicate(format: "assetId == %@", track.assetId)
            
            if let existingEntity = try? context.fetch(request).first {
                // Update existing entity
                existingEntity.name = track.name
                existingEntity.x = track.x
                existingEntity.y = track.y
                existingEntity.difficulty = track.difficulty
                existingEntity.duration = track.duration
                existingEntity.distance = track.distance
                existingEntity.descriptionText = track.description
                existingEntity.docId = track.docId
                existingEntity.isRecommended = recommendedTrackIds.contains(track.assetId) ||
                                               (track.docId != nil && recommendedTrackIds.contains(track.docId!)) ||
                                               recommendedTrackIds.contains { recommendedId in
                                                   let trackNameLower = track.name.lowercased()
                                                   let recommendedIdLower = recommendedId.lowercased()
                                                   return trackNameLower.replacingOccurrences(of: " ", with: "-").contains(recommendedIdLower) ||
                                                          trackNameLower.contains(recommendedIdLower.replacingOccurrences(of: "-", with: " "))
                                               }
                
                if let regionData = try? JSONEncoder().encode(track.region) {
                    existingEntity.regionData = regionData
                }
                if let lineData = try? JSONEncoder().encode(track.line) {
                    existingEntity.lineData = lineData
                }
            } else {
                // Create new entity
                let entity = track.toEntity(context: context)
                entity.isRecommended = recommendedTrackIds.contains(track.assetId) ||
                                       (track.docId != nil && recommendedTrackIds.contains(track.docId!)) ||
                                       recommendedTrackIds.contains { recommendedId in
                                           let trackNameLower = track.name.lowercased()
                                           let recommendedIdLower = recommendedId.lowercased()
                                           return trackNameLower.replacingOccurrences(of: " ", with: "-").contains(recommendedIdLower) ||
                                                  trackNameLower.contains(recommendedIdLower.replacingOccurrences(of: "-", with: " "))
                                       }
            }
        }
        
        do {
            try context.save()
            loadTracksFromDatabase()
            updateRecommendedTracksCoordinates()
        } catch {
            errorMessage = "Failed to save tracks to database: \(error.localizedDescription)"
        }
    }
    
    // DEPRECATED: This method is no longer used
    // Recommended tracks are loaded directly from recommendedTracks.json via loadRecommendedTracks()
    // This method is kept for reference but is not called anywhere
    private func updateRecommendedTracks() {
        // This method is deprecated - recommended tracks come from local JSON only
        // Keeping it for reference but it won't be called
    }
    
    func searchTracks(query: String) -> [Track] {
        guard !query.isEmpty else { return allTracks }
        let lowercasedQuery = query.lowercased()
        return allTracks.filter { track in
            track.name.lowercased().contains(lowercasedQuery) ||
            track.region.contains { $0.lowercased().contains(lowercasedQuery) } ||
            (track.description?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
