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
            let newJoke = try await jokeService.fetchJoke()
            joke = newJoke
        }catch{
            joke = Joke(content: "Failed to get joke try again!")
        }
        isLoading = false
    }
    
    func likeJoke(){
        
    }
    
    private func saveFavoriate(){
        
    }
    
    private func loadFavoriates(){
        
        
    }
    
    func shareJoke(){
        
    }
}
    
