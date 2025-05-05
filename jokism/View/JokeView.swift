// Updated JokeView.swift with swipe down functionality
import SwiftUI

struct JokeView: View {
    @StateObject private var sharedVM = SharedViewModel.shared
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    @State private var hasLoadedInitialJoke = false
    
    var body: some View {
        VStack {
            Text("Jokism")
                .font(.system(.headline, design: .monospaced))
                .bold()
                .padding(.top, 20)
                
            Spacer()
            
            ZStack {
                if let joke = sharedVM.jokeViewModel.joke {
                    JokeCard(joke: joke)
                        .offset(x: offset.width, y: offset.height)
                        .rotationEffect(.degrees(Double(offset.width) * 0.1))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    // Change color based on drag direction
                                    withAnimation {
                                        if abs(offset.width) > abs(offset.height) {
                                            // Horizontal swipe
                                            color = offset.width > 0 ? .green : .red
                                        } else if offset.height > 0 {
                                            // Downward swipe
                                            color = .blue
                                        }
                                    }
                                }
                                .onEnded { gesture in
                                    withAnimation {
                                        handleSwipe(translation: gesture.translation)
                                    }
                                }
                        )
                } else if !hasLoadedInitialJoke {
                    ProgressView("Loading jokes...")
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 25) {
                // Dislike Button
                Button(action: { handleDislike() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // New Joke Button (skip)
                Button(action: { handleSkip() }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Share Button
                Button(action: { shareJoke() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.purple)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Like Button
                Button(action: { handleLike() }) {
                    Image(systemName: "heart")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
        .onAppear {
            if !hasLoadedInitialJoke {
                Task {
                    await sharedVM.jokeViewModel.getNewJoke()
                    hasLoadedInitialJoke = true
                }
            }
        }
    }
    
    private func handleSwipe(translation: CGSize) {
        let swipeThreshold: CGFloat = 150
        
        // Determine if this is primarily a horizontal or vertical swipe
        if abs(translation.width) > abs(translation.height) {
            // Horizontal swipe
            if translation.width > swipeThreshold {
                // Right swipe - like
                offset = CGSize(width: 500, height: 0)
                handleLike()
            } else if translation.width < -swipeThreshold {
                // Left swipe - dislike
                offset = CGSize(width: -500, height: 0)
                handleDislike()
            } else {
                // Not enough horizontal movement - reset
                offset = .zero
                color = .black
            }
        } else {
            // Vertical swipe
            if translation.height > swipeThreshold {
                // Down swipe - skip/new joke
                offset = CGSize(width: 0, height: 500)
                handleSkip()
            } else {
                // Not enough vertical movement - reset
                offset = .zero
                color = .black
            }
        }
    }
    
    private func handleLike() {
        withAnimation {
            offset = CGSize(width: 500, height: 0)
            sharedVM.jokeViewModel.likeJoke()
            Task {
                await sharedVM.jokeViewModel.getNewJoke()
                offset = .zero
                color = .black
            }
        }
    }
    
    private func handleDislike() {
        withAnimation {
            offset = CGSize(width: -500, height: 0)
            sharedVM.jokeViewModel.dislikeJoke()
            Task {
                await sharedVM.jokeViewModel.getNewJoke()
                offset = .zero
                color = .black
            }
        }
    }
    
    private func handleSkip() {
        withAnimation {
            offset = CGSize(width: 0, height: 500)
            Task {
                await sharedVM.jokeViewModel.getNewJoke()
                offset = .zero
                color = .black
            }
        }
    }
    
    private func shareJoke() {
        if let joke = sharedVM.jokeViewModel.joke {
            let renderer = ImageRenderer(content: JokeShareCard(joke: joke))
            
            // Make sure the image renders at a good size
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
}

// A dedicated card for sharing
struct JokeShareCard: View {
    let joke: Joke
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Jokism")
                    .font(.system(.headline, design: .monospaced))
                    .bold()
                
                Spacer()
                
                Image(systemName: "face.smiling.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // The joke content
            VStack {
                Text(joke.content)
                    .font(.title2)
                    .padding(25)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // The app attribution
            HStack {
                Text("Shared from Jokism")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "face.smiling")
                    .foregroundColor(.yellow)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
        .frame(width: 1080, height: 1920)
        .background(Color(.systemGray6))
    }
}

// The card for displaying jokes in the main view
struct JokeCard: View {
    let joke: Joke
    
    var body: some View {
        VStack {
            ScrollView {
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
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
        }
        .padding(.horizontal)
    }
}
