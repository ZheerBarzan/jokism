//
//  joke.swift
//  jokism
//
//  Created by zheer barzan on 5/3/25.
//

import Foundation

struct Joke : Codable, Identifiable{
    
    let id: String
    let content: String
    
    init(id: String = UUID().uuidString, content: String) {
        self.id = id
        self.content = content
    }
}
