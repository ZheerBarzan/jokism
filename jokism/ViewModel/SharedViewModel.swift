import SwiftUI

@MainActor
class SharedViewModel: ObservableObject {
    static let shared = SharedViewModel()
    @Published var jokeViewModel: JokeViewModel
    
    private init() {
        self.jokeViewModel = JokeViewModel()
    }
} 