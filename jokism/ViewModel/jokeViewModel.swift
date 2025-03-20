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
    @Published var joke: Joke?
    @Published var isLoading = false
    @Published var favorites: [Joke] = []
    @AppStorage("favoriteJokes") private var favoriteJokesData: String? // Use String instead of Data
    private let jokeService = JokeService()
    private var seenJokes: Set<String> = []

    init() {
        loadFavorites()
    }

    func getNewJoke() async {
        isLoading = true
        do {
            var newJoke: Joke
            repeat {
                newJoke = try await jokeService.fetchJoke()
            } while seenJokes.contains(newJoke.id) // Prevent duplicates

            joke = newJoke
            seenJokes.insert(newJoke.id)
        } catch {
            joke = Joke(id: UUID().uuidString, content: "Failed to get joke. Try again!")
        }
        isLoading = false
    }

    func likeJoke() {
        guard let joke = joke, !favorites.contains(where: { $0.id == joke.id }) else { return }
        favorites.append(joke)
        saveFavorites()
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

    func shareJoke() -> String {
        guard let joke = joke else { return "" }
        return "\"\(joke.content)\" - via Jokism App 😆"
    }
}
