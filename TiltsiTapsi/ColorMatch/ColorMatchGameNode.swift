import SpriteKit

class ColorMatchGameNode: SKNode {
    var onComplete: (() -> Void)?
    var onTimeout: (() -> Void)?
    var numbersRevealed = false
    
    private var balls = [Ball]()
    private var mistakes = 0
    private let level: Int
    private let ballCount: Int
    private let size: CGSize
    private var isExploding = false
    
    private let appearanceDuration: Double = 1.0
    private let gameColors: [UIColor] = [.systemRed, .systemGreen, .systemBlue].shuffled()
    
    // Progress bar
    private let progressBarHeight: CGFloat = 16
    private let progressBarBackground: SKSpriteNode
    private let progressBar: SKSpriteNode
    private var timeoutAction: SKAction?
    
    init(level: Int, size: CGSize) {
        self.level = level
        self.ballCount = level + 9
        self.size = size
        
        // Initialize progress bar background
        progressBarBackground = SKSpriteNode(color: .darkGray, 
                                           size: CGSize(width: size.width, height: progressBarHeight))
        progressBarBackground.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBarBackground.position = CGPoint(x: 0, y: size.height - 56)
        progressBarBackground.zPosition = 100
        
        // Initialize progress bar
        progressBar = SKSpriteNode(color: .green, 
                                 size: CGSize(width: size.width, height: progressBarHeight))
        progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBar.position = CGPoint(x: 0, y: size.height - 56)
        progressBar.zPosition = 101
        
        super.init()
        name = "gameNode"  // Add name for easier identification
        
        addChild(progressBarBackground)
        addChild(progressBar)
        setupGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGame() {
        let ballDiameter = calculateBallSize(numberOfBalls: ballCount)
        let delayPerBall = appearanceDuration / Double(ballCount)
        
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnBall(size: ballDiameter)
        }
        
        let spawnSequence = SKAction.sequence([
            spawnAction,
            .wait(forDuration: delayPerBall)
        ])
        
        run(.sequence([
            .repeat(spawnSequence, count: ballCount),
            .wait(forDuration: 0.5),
            .run { [weak self] in
                self?.colorBallsInitially()
                self?.startTimeout()
                self?.numbersRevealed = true
            }
        ]))
    }
    
    private func spawnBall(size: CGFloat) {
        let ball = Ball(color: .gray, width: size)
        
        // Use proper margins to keep balls within scene bounds
        let margin: CGFloat = size
        ball.position = CGPoint(
            x: margin + .random(in: 0...(self.size.width - 2*margin)),
            y: margin + .random(in: 0...(self.size.height - 2*margin))
        )
        
        ball.createPhysicsBody()
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.restitution = 0.8
        ball.physicsBody?.friction = 0.3
        ball.physicsBody?.density = 1.0
        ball.physicsBody?.allowsRotation = true
        
        addChild(ball)
        balls.append(ball)
        
        ActionManager.shared.performAction(.ballAppear)
    }
    
    private func colorBallsInitially() {
        for ball in balls {
            ball.color = gameColors.randomElement() ?? .red
        }
    }
    
    private func calculateBallSize(numberOfBalls: Int) -> CGFloat {
        let screenArea = size.width * size.height
        let totalBallArea = screenArea * 0.4
        let ballArea = totalBallArea / CGFloat(numberOfBalls)
        return sqrt(ballArea / .pi) * 2
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard numbersRevealed, !isExploding else { return false }
        
        if let ballNode = nodes(at: location).first(where: { $0 is Ball }) as? Ball {
            let currentColorIndex = gameColors.firstIndex(of: ballNode.color) ?? 0
            let nextColorIndex = (currentColorIndex + 1) % gameColors.count
            let oldColor = ballNode.color
            
            ballNode.color = gameColors[nextColorIndex]
            ballNode.animateColorChange(from: oldColor)
            
            if oldColor == ballNode.color {
                mistakes += 1
            }
            
            ActionManager.shared.performAction(.itemCollected)
            checkGameOver()
        }
        return false
    }
    
    private func startTimeout() {
        let duration = calculateTimeout(level: level)
        
        let shrinkAction = SKAction.scaleX(to: 0, duration: duration)
        progressBar.run(shrinkAction)
        
        timeoutAction = .sequence([
            .wait(forDuration: duration),
            .run { [weak self] in
                guard let self = self, !self.isExploding else { return }
                self.handleTimeout()
            }
        ])
        
        run(timeoutAction!)
    }
    
    private func checkGameOver() {
        let firstColor = balls[0].color
        let allSameColor = balls.allSatisfy { $0.color == firstColor }
        
        if allSameColor && !isExploding {
            if let action = timeoutAction {
                removeAction(forKey: action.description)
            }
            explodeAllBalls()
            onComplete?()
        }
    }
    
    func calculateTimeout(level: Int) -> Double {
        let maxTimePerItem = 0.5   // T_max
        let minTimePerItem = 0.05    // T_min
        let decayRate = 0.05        // k

        // Number of balls grows with the level
        let numberOfBalls = 10 + level

        // Calculate time per item using exponential decay
        let timePerItem = minTimePerItem + (maxTimePerItem - minTimePerItem) * exp(-decayRate * Double(level))
        
        // Calculate total timeout
        return timePerItem * Double(numberOfBalls)
    }
    
    private func explodeAllBalls() {
        isExploding = true
        numbersRevealed = false
        let totalDuration = calculateTimeout(level: level)
        
        for (index, ball) in balls.enumerated() {
            let delay = Double(index)
            let waitAction = SKAction.wait(forDuration: delay)
            let explodeAction = ball.explode()
            
            ball.run(.sequence([waitAction, explodeAction])) {
                ball.removeFromParent()
            }
        }
        
        // Wait for all balls to explode before completing
        run(.sequence([
            .wait(forDuration: totalDuration),
            .run { [weak self] in
                self?.removeFromParent()
                self?.onComplete?()
            }
        ]))
    }
    
    private func handleTimeout() {
        isExploding = true
        numbersRevealed = false
        
        progressBar.run(.fadeOut(withDuration: 0.3))
        
        let freezeAction = SKAction.group([
            .fadeAlpha(to: 0.4, duration: 0.3),
            .colorize(with: .gray, colorBlendFactor: 1.0, duration: 0.3)
        ])
        
        for ball in balls {
            ball.run(freezeAction)
        }
        
        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                guard let self = self else { return }
                self.onTimeout?()
                
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
                for ball in self.balls {
                    ball.run(fadeOutAction) {
                        ball.removeFromParent()
                    }
                }
                
                self.run(.sequence([
                    .wait(forDuration: 0.3),
                    .run { self.removeFromParent() }
                ]))
            }
        ]))
    }
} 
