import SpriteKit

class OnboardingScene: SKScene {
    private let screens: [(title: String, text: String)] = [
        (
            "Welcome!",
            "🌟 Your brain is about to get a serious workout!\n\n⚫ Two ways to play: Challenge Mode or Individual Games."
        ),
        (
            "Challenge Mode",
            "🔥 Challenge Mode is the ultimate test!\n\n🎯 Play all four games in a row with just ONE life per game.\n\n🏆 How high can you score?"
        ),
        (
            "Reflexes & Speed",
            "⏳ Color Match – Can you make all balls the same color before time is up?\n\n⚡ Trail Maker – Tap numbers in order. Fast hands, fast mind!"
        ),
        (
            "Memory & Strategy",
            "🧠 Corsi Blocks – Remember and repeat the flashing sequence. Don't mess up!\n\n👀 Special Memory – Memorize the glowing balls. Tap them after they vanish!"
        ),
        (
            "Compete & Get Better",
            "🏆 Challenge yourself daily to improve!\n\n🎮 Game Center lets you track your progress and compete with others!"
        ),
        (
            "Let's Play!",
            "🎉 You're all set. Show us what you've got!"
        )
    ]
    
    private var currentScreen = 0
    private let horizontalMargin: CGFloat = 40
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        showCurrentScreen()
    }
    
    private func showCurrentScreen() {
        removeAllChildren()
        let screen = screens[currentScreen]
        
        // Create and setup main text first
        let textLabel = AppLabelNode(text: screen.text)
        textLabel.fontSize = 18
        textLabel.fontColor = .white
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = frame.width - (horizontalMargin * 2)
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(textLabel)
        
        // Now we can use the actual frame of the text label
        let textFrame = textLabel.calculateAccumulatedFrame()
        
        // Create and setup title
        let titleLabel = AppLabelNode(text: screen.title)
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .bottom
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: frame.midX, y: textFrame.maxY + 40)  // 40 points above text
        addChild(titleLabel)
        
        // Create and setup tap label
        let tapLabel = AppLabelNode(text: currentScreen == screens.count - 1 ? "Tap to start playing!" : "Tap to continue")
        tapLabel.fontSize = 16
        tapLabel.fontColor = .systemGray
        tapLabel.verticalAlignmentMode = .top
        tapLabel.horizontalAlignmentMode = .center
        tapLabel.position = CGPoint(x: frame.midX, y: textFrame.minY - 40)  // 40 points below text
        addChild(tapLabel)
        
        // Animate tap label
        tapLabel.run(.repeatForever(.sequence([
            .scale(by: 1.2, duration: 0.8),
            .scale(to: 1, duration: 0.7)
        ])))
        
        // Fade in animation
        [titleLabel, textLabel, tapLabel].forEach { node in
            node.alpha = 0
            node.run(.fadeIn(withDuration: 0.3))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentScreen += 1
        
        if currentScreen >= screens.count {
            completeOnboarding()
        } else {
            showCurrentScreen()
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        let menuScene = MenuScene(size: size)
        view?.presentScene(menuScene, transition: .fade(withDuration: 0.5))
    }
} 
