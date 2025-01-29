import SpriteKit

class FinalScoreScene: SKScene {
    struct ScoreData {
        let score: Int
        let bestScore: Int
        let isNewBestScore: Bool
        let infoLines: [String]
    }
    
    private let scoreData: ScoreData
    
    init(size: CGSize, scoreData: ScoreData) {
        self.scoreData = scoreData
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupScoreLabels()
        setupContinueLabel()
    }
    
    private func setupScoreLabels() {
        // Title
        let titleLabel = AppLabelNode(text: scoreData.isNewBestScore ? "New Best Score!" : "Final Score")
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 120)
        addChild(titleLabel)
        
        // Main score
        let scoreLabel = AppLabelNode(text: "\(scoreData.score)")
        scoreLabel.fontSize = 64
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height - 200)
        addChild(scoreLabel)
        
        // Best score (if not new best)
        if !scoreData.isNewBestScore {
            let bestScoreLabel = AppLabelNode(text: "Best: \(scoreData.bestScore)")
            bestScoreLabel.fontSize = 24
            bestScoreLabel.position = CGPoint(x: frame.midX, y: frame.height - 260)
            addChild(bestScoreLabel)
        }
        
        // Info lines
        for (index, info) in scoreData.infoLines.enumerated() {
            let infoLabel = AppLabelNode(text: info)
            infoLabel.fontSize = 20
            infoLabel.position = CGPoint(x: frame.midX, y: frame.height - 320 - CGFloat(index * 30))
            addChild(infoLabel)
        }
    }
    
    private func setupContinueLabel() {
        let tapLabel = AppLabelNode(text: "Tap anywhere to continue")
        tapLabel.fontSize = 20
        tapLabel.position = CGPoint(x: frame.midX, y: 100)
        tapLabel.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.5, duration: 0.8),
            .fadeAlpha(to: 1.0, duration: 0.8)
        ])))
        addChild(tapLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.presentScene(MenuScene(size: self.size))
    }
} 
