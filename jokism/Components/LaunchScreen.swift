//
//  LaunchScreen.swift
//  jokism
//
//  Created by zheer barzan on 20/3/25.
//


import SwiftUI

struct LaunchScreen: View {
    
    @State private var isActive = false
    
    
    var body: some View {
        
        if isActive{
            ContentView()
        }else{
            
            ZStack{
                Color.white
                    .ignoresSafeArea()
                Image("jokism")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation{
                        isActive = true
                    }
                }
                
            }
        }
    }
}
