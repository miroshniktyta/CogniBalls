import SpriteKit

class ChallengeIntroScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Title
        let titleLabel = AppUI.createTitle("4-Game Challenge",
            at: CGPoint(x: frame.midX, y: frame.height - 100))
        
        // Rules text
        let rulesText = "Complete all games in sequence\nOne life per game\nGet the highest total score!"
        let rulesLabel = AppUI.createInfoText(rulesText,
            at: CGPoint(x: frame.midX, y: frame.midY),
            width: frame.width - 80)
        
        // Tap label
        let tapLabel = AppUI.createTapLabel(
            text: "Tap to start the challenge",
            at: CGPoint(x: frame.midX, y: frame.height * 0.15)
        )
        
        [titleLabel, rulesLabel, tapLabel].forEach { addChild($0) }
        AppUI.fadeIn([titleLabel, rulesLabel, tapLabel])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ChallengeManager.shared.startChallenge()
        view?.presentScene(ColorMatchScene(size: size))
    }
} 
