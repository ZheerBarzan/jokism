//
//  SettingsView.swift
//  jokism
//
//  Created by zheer barzan on 19/3/25.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("dark_mode") private var isDarkMode: Bool = false



    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing:20){
                
               Toggle("Dark Mode", isOn: $isDarkMode)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                   
               
               
                
                Spacer()
                    

                
            }.padding(20)
            .navigationTitle("Settings")
                
        }
    }
}
