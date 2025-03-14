//
//  jokeService.swift
//  jokism
//
//  Created by zheer barzan on 6/3/25.
//

import Foundation

class JokeService{
    
    func fetchJoke() async throws -> Joke{
        let sources = [fetchIcanHazDadJoke, fetchJokeAPI, fetchChuckNorriesJoke]
        let randomSource = sources.randomElement()!
        return try await randomSource()
    }
    
    private func fetchIcanHazDadJoke() async throws -> Joke{
        let url = URL(string: "https://icanhazdadjoke.com/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(IcanHazDadJokeResponse.self, from: data)
        
        return Joke(id: response.id, content: response.joke)
    }
    
    
    private func fetchJokeAPI() async throws -> Joke{
        let url = URL(string: "https://v2.jokeapi.dev/joke/Any?type=single")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(JokeAPIResponse.self, from: data)
        
        return Joke(id: String(response.id), content: response.joke)

    }
    private func fetchChuckNorriesJoke() async throws -> Joke{
        let url = URL(string: "https://api.chucknorris.io/jokes/random")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChuckNorrisResponse.self, from: data)
        
        return Joke(id: response.id, content: response.joke)

    }
    
}


// API's
struct IcanHazDadJokeResponse: Codable{
    let id: String
    let joke: String
}

struct JokeAPIResponse: Codable{
    let id: String
    let joke: String
}

struct ChuckNorrisResponse: Codable{
    let id: String
    let joke: String
}


