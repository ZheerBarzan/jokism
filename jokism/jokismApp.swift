//
//  jokismApp.swift
//  jokism
//
//  Created by zheer barzan on 5/3/25.
//

import SwiftUI

@main
struct jokismApp: App {
    @StateObject private var jokeViewModel = JokeViewModel()
    @AppStorage("dark_mode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(jokeViewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
            
        }
    }
}
