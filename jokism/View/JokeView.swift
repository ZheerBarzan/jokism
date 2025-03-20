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
                
            }
        }
    }
}

#Preview {
    JokeView()
}
