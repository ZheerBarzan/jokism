//
//  jokeService.swift
//  jokism
//
//  Created by zheer barzan on 6/3/25.
//

import Foundation

/// Error types that can occur during joke fetching
enum JokeServiceError: Error {
    case invalidURL
    case decodingError
    case networkError
}

/// Service responsible for fetching jokes from various APIs
final class JokeService {
    
    // MARK: - Public Methods
    
    /// Fetches a random joke from one of the available sources
    /// - Returns: A Joke object containing the fetched joke
    /// - Throws: JokeServiceError if the fetch fails
    func fetchJoke() async throws -> Joke {
        let sources: [() async throws -> Joke] = [
            fetchIcanHazDadJoke,
            fetchJokeAPI,
            fetchChuckNorrisJoke
        ]
        
        guard let randomSource = sources.randomElement() else {
            throw JokeServiceError.networkError
        }
        
        return try await randomSource()
    }
    
    // MARK: - Private Methods
    
    private func fetchIcanHazDadJoke() async throws -> Joke {
        guard let url = URL(string: "https://icanhazdadjoke.com/") else {
            throw JokeServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(IcanHazDadJokeResponse.self, from: data)
        
        return Joke(id: response.id, content: response.joke)
    }
    
    private func fetchJokeAPI() async throws -> Joke {
        guard let url = URL(string: "https://v2.jokeapi.dev/joke/Any?type=single") else {
            throw JokeServiceError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(JokeAPIResponse.self, from: data)
        
        return Joke(id: String(response.id), content: response.joke)
    }
    
    private func fetchChuckNorrisJoke() async throws -> Joke {
        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else {
            throw JokeServiceError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChuckNorrisResponse.self, from: data)
        
        return Joke(id: response.id, content: response.value)
    }
}

// MARK: - API Response Models

/// Response model for icanhazdadjoke.com
private struct IcanHazDadJokeResponse: Codable {
    let id: String
    let joke: String
}

/// Response model for jokeapi.dev
private struct JokeAPIResponse: Codable {
    let id: Int
    let joke: String
    
    enum CodingKeys: String, CodingKey {
        case id, joke
    }
}

/// Response model for api.chucknorris.io
private struct ChuckNorrisResponse: Codable {
    let id: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case id, value
    }
}


