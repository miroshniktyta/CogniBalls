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
                currentGame: currentGame
            )
            view?.presentScene(intermediateScene, transition: .fade(withDuration: 0.5))
        } else {
            let bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
            let isNewBest = score > bestScore
            
            if isNewBest {
                UserDefaults.standard.set(score, forKey: bestScoreKey)
                // Submit individual game score to Game Center
                if let gameType = self as? ColorMatchScene {
                    GameCenterManager.shared.submitScore(score, forGameType: .colorMatch)
                } else if let _ = self as? NumberTrailScene {
                    GameCenterManager.shared.submitScore(score, forGameType: .numberTrail)
                } else if let _ = self as? CorsiTappingScene {
                    GameCenterManager.shared.submitScore(score, forGameType: .corsiTapping)
                } else if let _ = self as? SpatialMemoryScene {
                    GameCenterManager.shared.submitScore(score, forGameType: .spatialMemory)
                }
            }
            
            let scoreData = FinalScoreScene.ScoreData(
                score: score,
                bestScore: bestScore,
                isNewBestScore: isNewBest,
                infoLines: infoLines
            )
            let finalScene = FinalScoreScene(size: size, scoreData: scoreData)
            view?.presentScene(finalScene, transition: .fade(withDuration: 0.5))
        }
    }
} 
