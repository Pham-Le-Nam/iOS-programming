//
//  ContentView.swift
//  BubblePopGame
//
//  Created by Firas Al-Doghman on 29/3/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var playerName: String = ""//2Add for HighScore UserDefaults 12
    
    var body: some View {
        NavigationView{
            VStack {
                Label("Bubble Pop", systemImage: "")
                    .foregroundStyle(.mint)
                    .font(.largeTitle)
                    
                Spacer()
                
                NavigationLink(
                    destination: SettingsView(),
                    label: {
                        Text("New Game")
                            .font(.title)
                    })
                .padding(50)
                
                NavigationLink(
                    destination: HighScoreView(playerName: playerName, score: 0),//2Add for HighScore UserDefaults 13
                    label: {
                        Text("High Score")
                            .font(.title)
                    })
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
