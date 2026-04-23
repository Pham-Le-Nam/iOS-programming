import SwiftUI

// MARK: - Bubble Model
struct Bubble: Identifiable {
    let id = UUID()
    let color: BubbleColor
    var position: CGPoint
    var velocity: CGVector
}

// MARK: - Bubble Types + Probability + Points
enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black
    
    var points: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
    
    var colorValue: Color {
        switch self {
        case .red:
            return Color(red: 0.85, green: 0.1, blue: 0.1)   // deeper red
        case .pink:
            return Color(red: 1.0, green: 0.6, blue: 0.75)   // lighter, softer pink
        case .green:
            return .green
        case .blue:
            return .blue
        case .black:
            return .black
        }
    }
    
    // Probability: 40%, 30%, 15%, 10%, 5%
    static func random() -> BubbleColor {
        let roll = Int.random(in: 1...100)
        
        switch roll {
        case 1...40: return .red
        case 41...70: return .pink
        case 71...85: return .green
        case 86...95: return .blue
        default: return .black
        }
    }
}

// MARK: - View
struct StartGameView: View {
    
    var playerName: String
    var time: Double
    var numberOfBubbles: Int
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    @State private var timeLeft: Int
    @State private var score: Float = 0
    @State private var isGameFinished: Bool = false
    @State private var showHighScoreSheet: Bool = false
    @State private var isPostGame: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var bubbles: [Bubble] = []
    @State private var lastBubbleColor: BubbleColor? = nil
    @State private var countdown: Int = 3
    @State private var isCountingDown: Bool = true
    @State private var tickCounter = 0

    let bubbleSize: CGFloat = 60
    
    // MARK: Init
    init(playerName: String, time: Double, numberOfBubbles: Int) {
        self.playerName = playerName
        self.time = time
        self.numberOfBubbles = numberOfBubbles
        _timeLeft = State(initialValue: Int(time))
    }
    
    // MARK: Body
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // MARK: HUD (Top Bar)
                HStack {
                    Text("Time: \(timeLeft)")
                    Spacer()
                    Text("Score: \(String(format: "%.1f", score))")
                    Spacer()
                    Text("High Score: \(String(format: "%.1f", getHighestScore()))")
                }
                .padding()
                
                if isPostGame {
                    // Post-game functions
                    ZStack {
                        Color.black.opacity(0.3) // optional dim background

                        VStack(spacing: 20) {
                            Text("Final Score: \(String(format: "%.1f", score))")
                            Button("Replay") {
                                resetGame()
                            }
                            Button("Back to Settings") {
                                dismiss()
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if isCountingDown {
                    // Pre-game countdown
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        Text("\(countdown)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    // Start the game
                    // MARK: Bubbles
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(bubble.color.colorValue)
                            .frame(width: bubbleSize, height: bubbleSize)
                            .position(bubble.position)
                            .onTapGesture {
                                popBubble(bubble)
                            }
                    }
                }
            }
            .onReceive(timer) { _ in
                updateGame(in: geo.size)
            }
            .sheet(isPresented: $showHighScoreSheet, onDismiss: {
                isPostGame = true
            }) {
                HighScoreView(playerName: playerName, score: score)
            }
        }
    }
    
    // MARK: Game Loop
    private func updateGame(in size: CGSize) {
        // game finished
        guard timeLeft > 0 else {
            if !isGameFinished {
                isGameFinished = true
                showHighScoreSheet = true
            }
            return
        }
        
        tickCounter += 1
        if tickCounter % 60 == 0 {   // ~1 second
            // countdown phase
            if isCountingDown {
                if countdown > 1 {
                    countdown -= 1
                } else {
                    isCountingDown = false
                }
                return
            }
            
            timeLeft -= 1
            
            // randomly remove some existing bubbles
            bubbles.removeAll { _ in Bool.random() }
            
            // spawn new bubbles
            let availableSpace = numberOfBubbles - bubbles.count
            let newCount = Int.random(in: 0...availableSpace)
            
            for _ in 0..<newCount {
                bubbles.append(generateBubble(in: size))
            }
        }
        
        // MOVE bubbles
        for i in bubbles.indices {
            bubbles[i].position.y += bubbles[i].velocity.dy * 0.016
        }
        
        // REMOVE bubbles that go off-screen
        bubbles.removeAll {
            $0.position.x < -bubbleSize ||
            $0.position.x > size.width + bubbleSize ||
            $0.position.y < -bubbleSize ||
            $0.position.y > size.height + bubbleSize
        }
        
        
    }
    
    // MARK: Bubble Generator (no overlap)
    private func generateBubble(in size: CGSize) -> Bubble {
        
        var position: CGPoint
        
        repeat {
            position = CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: CGFloat.random(in: 120...(size.height - 50))
            )
        } while bubbles.contains(where: {
            distance($0.position, position) < bubbleSize
        })
        
        // speed increases as time decreases
        let progress = 1 - (Float(timeLeft) / Float(time))   // 0 → 1
        let baseSpeed: CGFloat = 80
        let maxExtra: CGFloat = 200
        let speed = baseSpeed + CGFloat(progress) * maxExtra

        // ONLY upward movement
        let velocity = CGVector(dx: 0, dy: speed)
        
        return Bubble(
            color: BubbleColor.random(),
            position: position,
            velocity: velocity
        )
    }
    
    // MARK: Pop Logic (Combo rule)
    private func popBubble(_ bubble: Bubble) {
        
        if let last = lastBubbleColor, last == bubble.color {
            let boosted = Float(Double(bubble.color.points) * 1.5)
            score += Float(boosted)
        } else {
            score += Float(bubble.color.points)
        }
        
        lastBubbleColor = bubble.color
        bubbles.removeAll { $0.id == bubble.id }
    }
    
    // MARK: Distance check (no overlap rule)
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    // MARK: Replay function
    private func resetGame() {
        timeLeft = Int(time)
        score = 0
        bubbles = []
        lastBubbleColor = nil
        
        isGameFinished = false
        isPostGame = false
        
        countdown = 3
        isCountingDown = true
    }
    
    private func getHighestScore() -> Float {
        guard let data = UserDefaults.standard.data(forKey: "PlayerScores"),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data),
              let maxScore = scores.map({ $0.score }).max()
        else {
            return 0
        }
        
        return maxScore
    }
}

// MARK: - Preview
#Preview {
    StartGameView(playerName: "Player", time: 60, numberOfBubbles: 15)
}
