import SpriteKit

enum GameType: String, CaseIterable {
    case colorMatch
    case numberTrail
    case corsiTapping
    case spatialMemory
    
    var title: String {
        switch self {
        case .colorMatch: return "Color Match"
        case .numberTrail: return "Number Trail"
        case .corsiTapping: return "Corsi Tapping"
        case .spatialMemory: return "Spatial Memory"
        }
    }
}

class ChallengeManager {
    static let shared = ChallengeManager()
    private init() {}
    
    var isInChallenge = false
    private(set) var currentGameIndex = 0
    private(set) var gameScores: [Int] = []
    
    let challengeBestScoreKey = "BestScoreChallenge"
    
    func startChallenge() {
        isInChallenge = true
        currentGameIndex = 0
        gameScores = []
    }
    
    func endChallenge() {
        isInChallenge = false
        currentGameIndex = 0
        gameScores = []
    }
    
    func addGameScore(_ score: Int) {
        gameScores.append(score)
    }
    
    func getTotalScore() -> Int {
        return gameScores.reduce(0, +)
    }
    
    var currentGame: GameType? {
        guard currentGameIndex < GameType.allCases.count else { return nil }
        return GameType.allCases[currentGameIndex]
    }
    
    var nextGame: GameType? {
        guard currentGameIndex + 1 < GameType.allCases.count else { return nil }
        return GameType.allCases[currentGameIndex + 1]
    }
    
    func moveToNextGame() -> Bool {
        currentGameIndex += 1
        return currentGameIndex < GameType.allCases.count
    }
} 
