import SpriteKit

class BaseGameScene: SKScene {
    var maxLives: Int {
        ChallengeManager.shared.isInChallenge ? 1 : 3
    }
    
    func showFinalScore(score: Int, bestScoreKey: String, infoLines: [String]) {
        if ChallengeManager.shared.isInChallenge {
            ChallengeManager.shared.addGameScore(score)
            
            // Get current game before moving to next
            let currentGame = ChallengeManager.shared.currentGame
            
            // Move to next game index
            let nextGame = ChallengeManager.shared.nextGame
            
            let intermediateScene = ChallengeScoreScene(
                size: size,
                score: score,
                nextGame: nextGame,
                currentGame: currentGame  // Pass the current game
            )
            view?.presentScene(intermediateScene, transition: .fade(withDuration: 0.5))
        } else {
            let scoreData = FinalScoreScene.ScoreData(
                score: score,
                bestScore: UserDefaults.standard.integer(forKey: bestScoreKey),
                isNewBestScore: score > UserDefaults.standard.integer(forKey: bestScoreKey),
                infoLines: infoLines
            )
            let finalScene = FinalScoreScene(size: size, scoreData: scoreData)
            view?.presentScene(finalScene, transition: .fade(withDuration: 0.5))
        }
    }
} 
