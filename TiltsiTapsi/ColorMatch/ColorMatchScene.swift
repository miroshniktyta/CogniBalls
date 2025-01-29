import SpriteKit

class ColorMatchScene: BaseGameScene {
    // MARK: - Properties
    private let navBarHeight: CGFloat = 48
    private lazy var lives: Int = maxLives {
        didSet {
            navigationBar?.updateLives(lives, max: maxLives)
            if lives <= 0 {
                showFinalScore()
            }
        }
    }
    
    private var currentStep = 0 {
        didSet {
            navigationBar?.updateSteps(currentStep)
        }
    }
    private let startingBallCount = 6
    
    // UI Elements
    private var gameNode: ColorMatchGameNode? {
        willSet {
            // Ensure proper cleanup of old node
            gameNode?.removeFromParent()
        }
    }
    private var stepsLabel: AppLabelNode!
    private var livesLabel: AppLabelNode!
    private var tapToStartLabel = AppLabelNode(text: "Tap to Start")
    private var infoLabel: AppLabelNode!
    
    private var navigationBar: GameNavigationBar!
    
    private let bestScoreKey = "BestScoreColorMatch"
    private var totalBallsMatched = 0
    
    private var gravityAngle: CGFloat = 0
    private var isGravityActive = false
    private let gravityRadius: CGFloat = 4.0  // Strength of gravity
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysics()
        setupNavigation()
        setupTapToStartLabel()
        isGravityActive = false  // Ensure gravity is off initially
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        let extendedFrame = CGRect(x: frame.minX, y: frame.minY,
                                 width: frame.width,
                                 height: frame.height - navBarHeight - 16)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: extendedFrame)
    }
    
    private func setupNavigation() {
        navigationBar = GameNavigationBar(width: frame.width)
        navigationBar.position = CGPoint(x: 0, y: frame.height - navigationBar.frame.height)
        navigationBar.onBackButtonTap = { [weak self] in
            self?.transitionBackToMenu()
        }
        addChild(navigationBar)
        
        // Initial values
        navigationBar.updateLives(lives, max: maxLives)
        navigationBar.updateSteps(currentStep)
    }
    
    // MARK: - Game Flow
    private func calculateScore() -> Int {
        return totalBallsMatched * 10
    }
    
    private func getBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: bestScoreKey)
    }
    
    private func updateBestScore(_ score: Int) {
        let currentBest = getBestScore()
        if score > currentBest {
            UserDefaults.standard.set(score, forKey: bestScoreKey)
        }
    }
    
    private func startNextStep() {
        let node = ColorMatchGameNode(level: currentStep, size: size)
        
        node.onComplete = { [weak self] in
            guard let self = self else { return }
            self.totalBallsMatched += self.startingBallCount + self.currentStep
            self.currentStep += 1
            self.startNextStep()
        }
        
        node.onTimeout = { [weak self] in
            guard let self = self else { return }
            self.lives -= 1
            if self.lives > 0 {
                self.startNextStep()
            }
        }
        
        gameNode = node
        addChild(node)
        
        // Start gravity movement when game starts
        isGravityActive = true
    }
    
    // MARK: - UI Setup
    private func setupTapToStartLabel() {
        infoLabel = AppLabelNode(text: "Tap balls to change their color.\nMake all balls the same color!")
        infoLabel.numberOfLines = 0
        infoLabel.fontSize = 18
        infoLabel.fontColor = .white
        infoLabel.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        addChild(infoLabel)
        
        tapToStartLabel.fontSize = 18
        tapToStartLabel.verticalAlignmentMode = .top
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 40)
        addChild(tapToStartLabel)
        tapToStartLabel.run(.repeatForever(.sequence([
            .scale(by: 1.2, duration: 0.8),
            .scale(to: 1, duration: 0.7)
        ])))
    }
    
    // MARK: - Scene Navigation
    func showFinalScore() {
        isGravityActive = false  // Stop gravity when game ends
        let score = calculateScore()
        
        // Use the base class showFinalScore method instead of creating FinalScoreScene directly
        showFinalScore(
            score: score,
            bestScoreKey: bestScoreKey,
            infoLines: [
                "Rounds completed: \(currentStep)",
                "Balls matched: \(totalBallsMatched)"
            ]
        )
    }
    
    func transitionBackToMenu() {
        isGravityActive = false  // Stop gravity when leaving
        view?.presentScene(MenuScene(size: self.size))
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let _ = nodes(at: location).first(where: { $0.name == "backButton" }) {
            ActionManager.shared.performAction(.buttonTap)
            transitionBackToMenu()
            return
        }
        
        if tapToStartLabel.parent != nil {
            tapToStartLabel.removeFromParent()
            infoLabel.removeFromParent()
            startNextStep()
            return
        }
        
        gameNode?.handleTap(at: location)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGravityActive else { return }
        
        // Slower rotation for more gentle movement
        let gravitySpeed: CGFloat = 0.015
        gravityAngle += gravitySpeed
        
        // Create circular gravity movement
        let gravityDirection = CGVector(
            dx: cos(gravityAngle) * gravityRadius,
            dy: sin(gravityAngle) * gravityRadius
        )
        physicsWorld.gravity = gravityDirection
    }
} 
