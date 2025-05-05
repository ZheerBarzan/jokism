// Updated functionality in JokeViewModel.swift
// Add this import at the top of the file
import SwiftUI

// Add the ImageRenderer support at the top of the file
// This is used for rendering SwiftUI views to UIImage
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class JokeViewModel: ObservableObject {
    @Published private(set) var joke: Joke?
    @Published var isLoading = false
    @Published var favorites: [Joke] = []
    @AppStorage("favoriteJokes") private var favoriteJokesData: String?
    @AppStorage("seenJokes") private var seenJokesData: String?
    @AppStorage("dislikedJokes") private var dislikedJokesData: String?
    
    private let jokeService = JokeService()
    private var seenJokes: Set<String> = []
    private var dislikedJokes: Set<String> = []
    
    init() {
        loadFavorites()
        loadSeenJokes()
        loadDislikedJokes()
    }
    
    func getNewJoke() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Try up to 5 times to get a new, unseen, not-disliked joke
            for _ in 0..<5 {
                let newJoke = try await jokeService.fetchJoke()
                
                // Skip if we've seen or disliked this joke
                if !seenJokes.contains(newJoke.id) && !dislikedJokes.contains(newJoke.id) {
                    self.joke = newJoke
                    seenJokes.insert(newJoke.id)
                    saveSeenJokes()
                    return
                }
            }
            // If we couldn't get an unseen joke after 5 tries, just use the last one
            let lastTry = try await jokeService.fetchJoke()
            self.joke = lastTry
            seenJokes.insert(lastTry.id)
            saveSeenJokes()
        } catch {
            print("Error fetching joke: \(error)")
        }
    }
    // Add to your JokeViewModel.swift

    @MainActor
    func updateFavorites(_ newFavorites: [Joke]) {
        // Use proper state management
        withAnimation {
            self.favorites = newFavorites
            saveFavorites()
            
            // Force an objectWillChange notification
            self.objectWillChange.send()
        }
    }

    func likeJoke() {
        guard let currentJoke = joke else { return }
        
        // Add to favorites only if not already there
        if !favorites.contains(where: { $0.id == currentJoke.id }) {
            // Update favorites with animation
            withAnimation {
                favorites.append(currentJoke)
                saveFavorites()
                
                // Force an objectWillChange notification
                self.objectWillChange.send()
            }
        }
        
        joke = nil // Clear the current joke
    }
    
  
    
    func dislikeJoke() {
        guard let currentJoke = joke else { return }
        
        // Add to disliked set
        dislikedJokes.insert(currentJoke.id)
        saveDislikedJokes()
        
        joke = nil // Clear the current joke
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites),
           let jsonString = String(data: encoded, encoding: .utf8) {
            favoriteJokesData = jsonString
        }
    }
    
    private func loadFavorites() {
        if let jsonString = favoriteJokesData,
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Joke].self, from: data) {
            favorites = decoded
        }
    }
    
    private func saveSeenJokes() {
        if let encoded = try? JSONEncoder().encode(Array(seenJokes)),
           let jsonString = String(data: encoded, encoding: .utf8) {
            seenJokesData = jsonString
        }
    }
    
    private func loadSeenJokes() {
        if let jsonString = seenJokesData,
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            seenJokes = Set(decoded)
        }
    }
    
    private func saveDislikedJokes() {
        if let encoded = try? JSONEncoder().encode(Array(dislikedJokes)),
           let jsonString = String(data: encoded, encoding: .utf8) {
            dislikedJokesData = jsonString
        }
    }
    
    private func loadDislikedJokes() {
        if let jsonString = dislikedJokesData,
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            dislikedJokes = Set(decoded)
        }
    }
    
    func shareJoke() -> String {
        guard let joke = joke else { return "" }
        return "\"\(joke.content)\" - via Jokism App 😆"
    }
    
    func removeFavorite(_ joke: Joke) {
        favorites.removeAll { $0.id == joke.id }
        saveFavorites()
    }
   
}
