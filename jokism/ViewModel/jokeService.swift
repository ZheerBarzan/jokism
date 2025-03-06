//
//  jokeService.swift
//  jokism
//
//  Created by zheer barzan on 6/3/25.
//

import Foundation

class JokeService{
    
    
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


