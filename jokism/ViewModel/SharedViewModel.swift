import SwiftUI
import Combine

@MainActor
class SharedViewModel: ObservableObject {
    static let shared = SharedViewModel()
    @Published var jokeViewModel: JokeViewModel
    
    // Add cancellables to manage publishers
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.jokeViewModel = JokeViewModel()
        
        // Listen for changes in the jokeViewModel and republish them
        jokeViewModel.$favorites
            .dropFirst() // Skip the initial value
            .sink { [weak self] _ in
                // This forces an objectWillChange notification
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
