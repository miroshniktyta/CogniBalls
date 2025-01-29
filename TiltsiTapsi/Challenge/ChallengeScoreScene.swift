import SpriteKit

class ChallengeScoreScene: SKScene {
    init(size: CGSize, score: Int, nextGame: GameType?, currentGame: GameType?) {
        super.init(size: size)
        self.backgroundColor = .black
        
        // Game completion title
        let titleLabel = AppUI.createTitle("\(currentGame!.title) completed!", 
            at: CGPoint(x: frame.midX, y: frame.height - 100))
        
        // Score info
        let scoreLabel = AppUI.createInfoText("Your score: \(score)",
            at: CGPoint(x: frame.midX, y: frame.midY + 20))
        
        // Next game or completion text
        let nextText = nextGame != nil ? "Next game: \(nextGame!.title)" : "Challenge Complete!"
        let nextLabel = AppUI.createInfoText(nextText,
            at: CGPoint(x: frame.midX, y: frame.midY - 40))
        
        // Tap label
        let tapLabel = AppUI.createTapLabel(
            text: "Tap to continue",
            at: CGPoint(x: frame.midX, y: frame.height * 0.15)
        )
        
        [titleLabel, scoreLabel, nextLabel, tapLabel].forEach { addChild($0) }
        AppUI.fadeIn([titleLabel, scoreLabel, nextLabel, tapLabel])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ChallengeManager.shared.moveToNextGame() {
            print("Moving to next game")
            presentNextGame()
        } else {
            print("Presenting final score")
            presentFinalScore()
        }
    }
    
    private func presentNextGame() {
        guard let nextGame = ChallengeManager.shared.currentGame else {
            print("No next game found")
            return
        }
        print("Presenting game: \(nextGame.title)")
        
        let nextScene: SKScene
        switch nextGame {
        case .colorMatch:
            nextScene = ColorMatchScene(size: size)
        case .numberTrail:
            nextScene = NumberTrailScene(size: size)
        case .corsiTapping:
            nextScene = CorsiTappingScene(size: size)
        case .spatialMemory:
            nextScene = SpatialMemoryScene(size: size)
        }
        
        view?.presentScene(nextScene, transition: .fade(withDuration: 0.5))
    }
    
    private func presentFinalScore() {
        let totalScore = ChallengeManager.shared.getTotalScore()
        let bestScore = UserDefaults.standard.integer(forKey: ChallengeManager.shared.challengeBestScoreKey)
        let isNewBest = totalScore > bestScore
        
        if isNewBest {
            UserDefaults.standard.set(totalScore, forKey: ChallengeManager.shared.challengeBestScoreKey)
            // Submit challenge score to Game Center (passing nil for gameType indicates challenge mode)
            GameCenterManager.shared.submitScore(totalScore, forGameType: nil)
        }
        
        let scoreData = FinalScoreScene.ScoreData(
            score: totalScore,
            bestScore: bestScore,
            isNewBestScore: isNewBest,
            infoLines: ChallengeManager.shared.gameScores.enumerated().map { index, score in
                "\(GameType.allCases[index].title): \(score)"
            }
        )
        
        let finalScene = FinalScoreScene(size: size, scoreData: scoreData)
        view?.presentScene(finalScene)
        
        ChallengeManager.shared.endChallenge()
    }
} 
