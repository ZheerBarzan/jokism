//
//  ContentView.swift
//  jokism
//
//  Created by zheer barzan on 5/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            FavoraitesJokeView()
                .tabItem {
                    Label("Favorites", systemImage: "Heart.fill")
                }
            JokeView()
                .tabItem {
                    Label("Jokes", systemImage: "Smiley")
                }
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "Gear")
                }
            
        }
        

    }
}

#Preview {
    ContentView()
}
