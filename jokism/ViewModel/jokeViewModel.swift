//
//  jokeViewModel.swift
//  jokism
//
//  Created by zheer barzan on 15/3/25.
//
import SwiftUI
import Foundation

@MainActor
class JokeViewModel: ObservableObject {
    @Published private(set) var joke: Joke?
    @Published var isLoading = false
    @Published var favorites: [Joke] = []
    @AppStorage("favoriteJokes") private var favoriteJokesData: String?
    @AppStorage("seenJokes") private var seenJokesData: String?
    
    private let jokeService = JokeService()
    private var seenJokes: Set<String> = []
    
    init() {
        loadFavorites()
        loadSeenJokes()
    }
    
    func getNewJoke() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Try up to 3 times to get a new, unseen joke
            for _ in 0..<3 {
                let newJoke = try await jokeService.fetchJoke()
                if !seenJokes.contains(newJoke.id) {
                    self.joke = newJoke
                    seenJokes.insert(newJoke.id)
                    saveSeenJokes()
                    return
                }
            }
            // If we couldn't get an unseen joke after 3 tries, just use the last one
            let lastTry = try await jokeService.fetchJoke()
            self.joke = lastTry
            seenJokes.insert(lastTry.id)
            saveSeenJokes()
        } catch {
            print("Error fetching joke: \(error)")
        }
    }
    
    func likeJoke() {
        guard let currentJoke = joke else { return }
        favorites.append(currentJoke)
        saveFavorites()
        joke = nil // Clear the current joke
    }
    
    func dislikeJoke() {
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
    
    func shareJoke() -> String {
        guard let joke = joke else { return "" }
        return "\"\(joke.content)\" - via Jokism App 😆"
    }
    
    func removeFavorite(_ joke: Joke) {
        favorites.removeAll { $0.id == joke.id }
        saveFavorites()
    }
    // Add this method to your JokeViewModel class
@MainActor
func updateFavorites(_ newFavorites: [Joke]) {
    favorites = newFavorites
    saveFavorites()
}
}
