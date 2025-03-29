//
//  JokeView.swift
//  jokism
//
//  Created by zheer barzan on 19/3/25.
//

import SwiftUI

struct JokeView: View {
    @StateObject private var sharedVM = SharedViewModel.shared
    @State private var offset: CGFloat = 0
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
                        .offset(x: offset)
                        .rotationEffect(.degrees(Double(offset) * 0.1))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation.width
                                    // Change color based on drag direction
                                    withAnimation {
                                        color = offset > 0 ? .green : .red
                                    }
                                }
                                .onEnded { gesture in
                                    withAnimation {
                                        handleSwipe(width: gesture.translation.width)
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
                
                // Share Button
                Button(action: { shareJoke() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Like Button
                Button(action: { handleLike() }) {
                    Image(systemName: "checkmark")
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
    
    private func handleSwipe(width: CGFloat) {
        let swipeThreshold: CGFloat = 150
        
        if width > swipeThreshold {
            offset = 500
            handleLike()
        } else if width < -swipeThreshold {
            offset = -500
            handleDislike()
        } else {
            offset = 0
            color = .black
        }
    }
    
    private func handleLike() {
        withAnimation {
            offset = 500
            sharedVM.jokeViewModel.likeJoke()
            Task {
                await sharedVM.jokeViewModel.getNewJoke()
                offset = 0
                color = .black
            }
        }
    }
    
    private func handleDislike() {
        withAnimation {
            offset = -500
            sharedVM.jokeViewModel.dislikeJoke()
            Task {
                await sharedVM.jokeViewModel.getNewJoke()
                offset = 0
                color = .black
            }
        }
    }
    
    private func shareJoke() {
        let text = sharedVM.jokeViewModel.shareJoke()
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
/*
struct JokeCard: View {
    let joke: Joke
    
    var body: some View {
        VStack {
            Text(joke.content)
                .font(.title2)
                .padding(25)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}

#Preview {
    JokeView()
}

*/
