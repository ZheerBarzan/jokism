//
//  JokeView.swift
//  jokism
//
//  Created by zheer barzan on 19/3/25.
//

import SwiftUI

struct JokeView: View {
    @StateObject private var jokeViewModel = JokeViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            
            if let joke = jokeViewModel.joke{
                Text(joke.content)
                    .font(.title2)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                if gesture.translation.width > 100{
                                    Task{ await jokeViewModel.getNewJoke() }
                                }
                            }
                    )
                
            }else{
                ProgressView("Cooking up some jokes...")
            }
            Spacer()
            
            
            HStack{
                
                Button(action: {
                    jokeViewModel.likeJoke()
                }, label: {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        
                })
                
                //Spacer()
                
                Button(action: {
                    shareJoke()
                },label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    
                })
            }
            .padding(.horizontal,50)
        }
        .onAppear{
            Task{ await jokeViewModel.getNewJoke() }
        }
    }
    
    private func shareJoke(){
        let text = jokeViewModel.shareJoke()
        let activityViewContorller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene{
            scene.windows.first?.rootViewController?.present(activityViewContorller, animated: true, completion: nil)
        }
    }
           
}

#Preview {
    JokeView()
}
