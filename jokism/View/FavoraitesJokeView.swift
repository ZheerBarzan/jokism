//
//  FavoraitesJokeView.swift
//  jokism
//
//  Created by zheer barzan on 19/3/25.
//

import SwiftUI

import SwiftUI

struct FavoraitesJokeView: View {
    // Use StateObject to ensure the view model stays alive
    @StateObject private var sharedVM = SharedViewModel.shared
    @State private var selectedJoke: Joke?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            Group {
                if sharedVM.jokeViewModel.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No favorite jokes yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Use ForEach with id parameter to ensure proper identity tracking
                    List {
                        ForEach(sharedVM.jokeViewModel.favorites, id: \.id) { joke in
                            JokeListItem(joke: joke)
                                .contentShape(Rectangle()) // Make the entire cell tappable
                                .onTapGesture {
                                    selectedJoke = joke
                                    showingDetail = true
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        shareJoke(joke)
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteJoke(joke)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $showingDetail) {
                if let joke = selectedJoke {
                    FavoriteJokeDetailView(
                        joke: joke,
                        onDelete: {
                            showingDetail = false
                            deleteJoke(joke)
                        },
                        onShare: { shareJoke(joke) }
                    )
                }
            }
        }
    }
    
    private func deleteJoke(_ joke: Joke) {
        // If this is the currently selected joke, close the detail view
        if selectedJoke?.id == joke.id {
            showingDetail = false
        }
        
        // Use a safer way to remove favorites
        // Create a new array with the joke filtered out
        let updatedFavorites = sharedVM.jokeViewModel.favorites.filter { $0.id != joke.id }
        
        // Update on the main thread with proper animation
        DispatchQueue.main.async {
            // Use the updateFavorites method which will handle state management properly
            sharedVM.jokeViewModel.updateFavorites(updatedFavorites)
        }
    }
    
    private func shareJoke(_ joke: Joke) {
        // Create and share a joke image
        let renderer = ImageRenderer(content: JokeShareCard(joke: joke))
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1920)
        
        if let uiImage = renderer.uiImage {
            let activityViewController = UIActivityViewController(
                activityItems: [uiImage],
                applicationActivities: nil
            )
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let windowScene = scene.windows.first?.rootViewController {
                activityViewController.popoverPresentationController?.sourceView = windowScene.view
                windowScene.present(activityViewController, animated: true)
            }
        }
    }
}

struct JokeListItem: View {
    let joke: Joke
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("😂")
                    .font(.title2)
                    .padding(.trailing, 8)
                
                Text(joke.content)
                    .lineLimit(3)
                    .font(.system(.body))
                    .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }
}


// Updated FavoriteJokeDetailView in FavoraitesJokeView.swift

struct FavoriteJokeDetailView: View {
    let joke: Joke
    let onDelete: () -> Void
    let onShare: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Joke display
                    JokeCard(joke: joke)
                        .padding(.top, 20)
                    
                    // Action buttons
                    HStack(spacing: 50) {
                        // Delete button
                        Button(action: {
                            onDelete()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red)
                                    .frame(width: 60, height: 60)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                
                                Text("Delete")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Share button
                        Button(action: {
                            onShare()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                    .frame(width: 60, height: 60)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                
                                Text("Share")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationTitle("Favorite Joke")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// A view that creates and shares a joke image
struct ShareJokeImageView: UIViewControllerRepresentable {
    let joke: Joke
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let renderer = ImageRenderer(content: JokeShareCard(joke: joke))
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1920)
        
        let image = renderer.uiImage ?? UIImage()
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#Preview {
    FavoraitesJokeView()
}
