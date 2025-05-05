//
//  FavoraitesJokeView.swift
//  jokism
//
//  Created by zheer barzan on 19/3/25.
//

import SwiftUI

struct FavoraitesJokeView: View {
    @StateObject private var sharedVM = SharedViewModel.shared
    @State private var selectedJoke: Joke?
    @State private var showingDetail = false
    // Force view to refresh when this changes
    @State private var refreshTrigger = UUID()
    
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
                    List {
                        ForEach(sharedVM.jokeViewModel.favorites) { joke in
                            JokeListItem(joke: joke)
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
            // This forces the view to refresh when refreshTrigger changes
            .id(refreshTrigger)
        }
    }
    
    private func deleteJoke(_ joke: Joke) {
        // If this is the currently selected joke, close the detail view
        if selectedJoke?.id == joke.id {
            showingDetail = false
        }
        
        // Create a local copy to avoid capturing the reference
        let jokeToDelete = joke
        
        // First update the UI by directly filtering out the removed joke
        let currentFavorites = sharedVM.jokeViewModel.favorites
        let updatedFavorites = currentFavorites.filter { $0.id != jokeToDelete.id }
        
        // Update the view model directly on the main thread
        DispatchQueue.main.async {
            withAnimation {
                // Directly update the favorites array
                sharedVM.jokeViewModel.updateFavorites(updatedFavorites)
                // Force a refresh of the entire view
                self.refreshTrigger = UUID()
            }
        }
    }
    
    private func shareJoke(_ joke: Joke) {
        let text = "\"\(joke.content)\" - via Jokism App 😆"
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let windowScene = scene.windows.first?.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = windowScene.view
            windowScene.present(activityViewController, animated: true)
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
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 20)
                    
                    // Nice display of the joke
                    VStack {
                        Text(joke.content)
                            .font(.title2)
                            .padding(25)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Action buttons in a nice layout
                    HStack(spacing: 30) {
                        // Delete button
                        Button(action: {
                            onDelete()
                        }) {
                            VStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.red)
                                    .padding(20)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                
                                Text("Delete")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Share button
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(20)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                
                                Text("Share")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    .padding(.horizontal)
                }
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
            .sheet(isPresented: $showingShareSheet) {
                // Use our new sharing approach with an image
                ShareJokeImageView(joke: joke)
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
