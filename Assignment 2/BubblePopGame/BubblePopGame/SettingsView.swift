//
//  SettingsView.swift
//  BubblePopGame
//
//  Created by Firas Al-Doghman on 29/3/2024.
//

import SwiftUI

struct SettingsView: View {
  //  @StateObject var highScoreViewModel = HighScoreViewModel()
    @State private var countdownInput = ""
    @State private var countdownValue: Double = 60
    @State private var numberOfBubbles: Double = 15
    @State private var playerName: String = "" //1Add for name UserDefaults 1
    var body: some View {
            VStack{
                Label("Settings", systemImage: "")
                    .foregroundStyle(.green)
                    .font(.title)
                    Spacer()
                Text("Enter Your Name:")
                
                TextField("Enter Name", text: $playerName)//1Add for name UserDefaults 2
                    .padding()
                    Spacer()
                Text("Game Time")
                Slider(value: $countdownValue, in: 0...60, step: 1)
                    .padding()
                    .onChange(of: countdownValue, perform: { value in
                        countdownInput = "\(Int(value))"
                    })
                Text(" \(Int(countdownValue))")
                    .padding()

                Text("Max Number of Bubbles")
                Slider(value: $numberOfBubbles, in: 0...15, step: 1)
                    .padding()
                                
                Text("\(Int(numberOfBubbles))")
                                    .padding()
                NavigationLink(
                    destination: StartGameView(playerName: playerName, time: countdownValue, numberOfBubbles: Int(numberOfBubbles)),//1Add for name UserDefaults 3
                    label: {
                        Text("Start Game")
                            .font(.title)
                    })
                Spacer()
                
            }
            .padding()
            .onDisappear {
                UserDefaults.standard.set(playerName, forKey: "PlayerName")
            }//1Add for name UserDefaults 4
        }
}
#Preview {
    SettingsView()
}
