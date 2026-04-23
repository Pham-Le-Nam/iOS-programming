import SwiftUI

// MARK: - Bubble Model
struct Bubble: Identifiable {
    let id = UUID()
    let color: BubbleColor
    var position: CGPoint
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
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
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
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var timeLeft: Int
    @State private var score: Int = 0
    @State private var isGameFinished: Bool = false
    
    @State private var bubbles: [Bubble] = []
    @State private var lastBubbleColor: BubbleColor? = nil
    
    let maxBubbles = 15
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
                    Text("Time Left: \(timeLeft)")
                    
                    Spacer()
                    
                    Text("Score: \(score)")
                    
                    Spacer()
                    
                    Text("High Score")
                }
                .padding()
                
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
            .onReceive(timer) { _ in
                updateGame(in: geo.size)
            }
            .sheet(isPresented: $isGameFinished) {
                HighScoreView(playerName: playerName, score: score)
            }
        }
    }
    
    // MARK: Game Loop
    func updateGame(in size: CGSize) {
        
        guard timeLeft > 0 else {
            isGameFinished = true
            return
        }
        
        // countdown
        timeLeft -= 1
        
        // remove random bubbles (not popped ones)
        bubbles.removeAll { _ in Bool.random() }
        
        // add new bubbles (max 15 rule)
        let availableSpace = maxBubbles - bubbles.count
        let newCount = Int.random(in: 0...availableSpace)
        
        for _ in 0..<newCount {
            bubbles.append(generateBubble(in: size))
        }
    }
    
    // MARK: Bubble Generator (no overlap)
    func generateBubble(in size: CGSize) -> Bubble {
        
        var position: CGPoint
        
        repeat {
            position = CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: CGFloat.random(in: 120...(size.height - 50))
            )
        } while bubbles.contains(where: {
            distance($0.position, position) < bubbleSize
        })
        
        return Bubble(color: BubbleColor.random(), position: position)
    }
    
    // MARK: Pop Logic (Combo rule)
    func popBubble(_ bubble: Bubble) {
        
        if let last = lastBubbleColor, last == bubble.color {
            let boosted = Int(Double(bubble.color.points) * 1.5)
            score += boosted
        } else {
            score += bubble.color.points
        }
        
        lastBubbleColor = bubble.color
        bubbles.removeAll { $0.id == bubble.id }
    }
    
    // MARK: Distance check (no overlap rule)
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}

// MARK: - Preview
#Preview {
    StartGameView(playerName: "Player", time: 60, numberOfBubbles: 15)
}
