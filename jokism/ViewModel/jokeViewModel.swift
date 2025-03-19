//
//  jokeViewModel.swift
//  jokism
//
//  Created by zheer barzan on 15/3/25.
//

import SwiftUI
import Foundation

@MainActor
class JokeViewModel: Observable{
    @Published var joke : Joke?
    @Published var isLoading = false
    @Published var favoriates: [Joke] = []
    @AppStorage("favoriteJokes") private var favoriteJokesData: Data? // Stores liked jokes
    private let jokeService = JokeService()
    private var seenJokes: Set<String> = []
    
    init(){
        loadFavoriates()
    }
    func getNewJoke() async {
        isLoading = true
        
        do{
            var newJoke: Joke
            repeat{
                newJoke = try await jokeService.fetchJoke()
            } while seenJokes.contains(newJoke.id)
            
            joke = newJoke
            seenJokes.insert(newJoke.id)
        }catch{
            joke = Joke(content: "Failed to get joke try again!")
        }
        isLoading = false
    }
    
    func likeJoke(){
        guard let joke = joke, !favoriates.contains(where: {$0.id == joke.id}) else { return }
        favoriates.append(joke)
        saveFavoriate()
        
        
    }
    
    private func saveFavoriate(){
        if let encoded = try? JSONEncoder().encode(favoriates){
            favoriteJokesData = encoded
        }
    }
    
    private func loadFavoriates(){
        if let data = favoriteJokesData, let decoded = try? JSONDecoder().decode([Joke].self, from: data){
            favoriates = decoded
        }
    }
    
    func shareJoke() -> String{
        guard let joke = joke else { return "" }
        return "\"\(joke.content)\" - via Jokism App 😆"
    }
}
    
