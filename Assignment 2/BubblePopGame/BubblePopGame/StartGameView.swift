//
//  StartGameView.swift
//  BubblePopGame
//
//  Created by Firas Al-Doghman on 29/3/2024.
//

import SwiftUI

struct StartGameView: View {
    var playerName: String //1Add for name UserDefaults 5
    
    @State private var score:Int = 0 //2Add for HighScore UserDefaults 1
    @State private var isGameFinished: Bool = false //2Add for HighScore UserDefaults 2
    
    var body: some View {
        VStack{ //1Add for name UserDefaults 6
            Label("Game started !", systemImage: "")
                .foregroundStyle(.purple)
                .font(.title)
            Spacer()
            Text(" \(playerName)")//1Add for name UserDefaults 7
            Spacer()
            
            Button("Finish Game"){
                // Simulate finishing the game and calculating the score
                score = Int.random(in: 0...100)
                isGameFinished = true
            }//2Add for HighScore UserDefaults 3
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isGameFinished, content: {
            HighScoreView(playerName: playerName, score: score)
        })//2Add for HighScore UserDefaults 4
    }
}

#Preview {
    StartGameView(playerName: "")//1Add for name UserDefaults 8
}
