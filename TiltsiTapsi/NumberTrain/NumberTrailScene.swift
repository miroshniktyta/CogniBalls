import SpriteKit
import CoreMotion

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

class NumberTrailScene: BaseGameScene {
    // MARK: - Properties
    private let navBarHeight: CGFloat = 48
    private lazy var lives: Int = maxLives {
        didSet {
            livesLabel?.text = "\(lives)/\(maxLives)"
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
    private let startingBallCount = 12
    
    // UI Elements
    private var gameNode: NumberTrailGameNode? {
        willSet {
            // Ensure proper cleanup of old node
            gameNode?.removeFromParent()
        }
    }
    private var stepsLabel: AppLabelNode!
    private var livesLabel: AppLabelNode!
    private var tapToStartLabel = AppLabelNode(text: "Tap to Start")
    private var infoLabel: AppLabelNode!
    
    private let bestScoreKey = "BestScoreNumberTrail"
    private var totalBallsCollected = 0
    private var totalMistakes = 0
    
    private let motionManager = CMMotionManager()
    
    private var navigationBar: GameNavigationBar!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysics()
        setupNavigation()
        setupTapToStartLabel()
        setupMotion()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        let extendedFrame = CGRect(x: frame.minX, y: frame.minY,
                                 width: frame.width,
                                 height: frame.height - navBarHeight)  // Extra space for progress bar
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
    
    private func setupMotion() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            
            // Limit maximum gravity and add minimum gravity
            let maxGravity: CGFloat = 4.0  // Reduced from 6
            let minGravity: CGFloat = 0.5   // Minimum gravity for constant gentle movement
            
            // Calculate gravity with limits
            let dx = CGFloat(data.acceleration.x)
            let dy = CGFloat(-data.acceleration.y)
            
            let limitedDx = dx.clamped(min: -1, max: 1) * maxGravity
            let limitedDy = dy.clamped(min: -1, max: 1) * maxGravity
            
            // Add minimum gravity in the direction of tilt
            let finalDx = limitedDx + (dx >= 0 ? minGravity : -minGravity)
            let finalDy = limitedDy + (dy >= 0 ? minGravity : -minGravity)
            
            let gravity = CGVector(dx: finalDx, dy: finalDy)
            self?.physicsWorld.gravity = gravity
        }
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
    
    // MARK: - Game Flow
    private func calculateScore() -> Int {
        return (totalBallsCollected - totalMistakes) * 10
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
        let ballCount = startingBallCount + currentStep
        let node = NumberTrailGameNode(ballCount: ballCount, size: size)
        
        node.onComplete = { [weak self] in
            guard let self = self else { return }
            self.currentStep += 1  // Increment step only on completion
            self.startNextStep()
        }
        
        node.onBallCollected = { [weak self] in
            self?.totalBallsCollected += 1
        }
        
        node.onMistake = { [weak self] mistakes in
            self?.totalMistakes = mistakes
        }
        
        node.onTimeout = { [weak self] in
            guard let self = self else { return }
            self.lives -= 1
            if self.lives > 0 {
                self.startNextStep()  // Retry same step
            }
        }
        
        gameNode = node
        addChild(node)
    }
    
    // MARK: - UI Setup
    private func setupTapToStartLabel() {
        infoLabel = AppLabelNode(text: "Tap the numbers in order\n       1 - 2 - 3 and so on :)")
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
        let score = calculateScore()
        
        showFinalScore(
            score: score,
            bestScoreKey: bestScoreKey,
            infoLines: [
                "Rounds completed: \(currentStep)",
                "Balls collected: \(totalBallsCollected)",
                "Total mistakes: \(totalMistakes)"
            ]
        )
    }
    
    func transitionBackToMenu() {
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
}
