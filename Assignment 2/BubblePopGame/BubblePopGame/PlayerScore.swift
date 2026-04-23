//
//  PlayerScore.swift
//  BubblePopGame
//
//  Created by admin on 7/4/2024.
//

import Foundation
// 2Add HighScore List 1
struct PlayerScore: Identifiable, Codable {
    var id = UUID()
    let playerName: String
    var score: Float
}
