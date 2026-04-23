//
//  HighScoreView.swift
//  BubblePopGame
//
//  Created by Firas Al-Doghman on 29/3/2024.
//

import SwiftUI

struct HighScoreView: View {
    @State private var playerScores: [PlayerScore] = [] // 3Add HighScore List 2
    var playerName: String //2Add for HighScore UserDefaults 5
    var score: Float //2Add for HighScore UserDefaults 6
    
    var body: some View {
        VStack{ //2Add for HighScore UserDefaults 7
            Label("High Score", systemImage: "")
                .foregroundStyle(.red)
                .font(.title)
            
//            Text("Player: \(playerName)")
//                           .font(.headline)//2Add for HighScore UserDefaults 8
//            Text("Score: \(score)")
//                           .font(.headline)//2Add for HighScore UserDefaults 9
            
            List(playerScores.sorted(by: {$0.score > $1.score}).prefix(10)){ playerScore in
                Text("\(playerScore.playerName): \(String(format: "%.1f", playerScore.score))")
            } // 3Add HighScore List 3
            //Displaying the top 5 Scores only
            Spacer() //2Add for HighScore UserDefaults 10
        }
        .onAppear{
            loadPlayerScores()
            savePlayerScore()
        }// 3Add HighScore List 4
    }
    
    private func loadPlayerScores() {
        if let data = UserDefaults.standard.data(forKey: "PlayerScores") {
            let decoder = JSONDecoder()
            if let decodedPlayerScores = try? decoder.decode([PlayerScore].self, from: data) {
                playerScores = decodedPlayerScores
            }
        }
    }// 3Add HighScore List 5
    
    private func savePlayerScore() {
        let newPlayerScore = PlayerScore(playerName: playerName, score: score)
        playerScores.append(newPlayerScore)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(playerScores) {
            UserDefaults.standard.set(encoded, forKey: "PlayerScores")
        }
    }// 3Add HighScore List 6
}

#Preview {
    HighScoreView(playerName: "", score: 0) //2Add for HighScore UserDefaults 11
}
