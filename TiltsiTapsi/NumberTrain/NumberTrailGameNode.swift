import SpriteKit
import CoreMotion

class NumberTrailGameNode: SKNode {
    
    var onComplete: (() -> Void)?
    var onTimeout: (() -> Void)?
    var onBallCollected: (() -> Void)?
    var onMistake: ((Int) -> Void)?
    var numbersRevealed = false
    
    private var balls = [NumberedBall]()
    private var currentNumber = 1
    private var mistakesInCurrentRound = 0
    private let ballCount: Int
    private let size: CGSize

    private let appearanceDuration: Double = 1.0
    
    // Progress bar
    private let progressBarHeight: CGFloat = 16
    private let progressBarBackground: SKSpriteNode
    private let progressBar: SKSpriteNode
    private var timeoutAction: SKAction?
    
    private var isExploding = false
    
    init(ballCount: Int, size: CGSize) {
        self.ballCount = ballCount
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
        
        let spawnSequence = SKAction.sequence([spawnAction, SKAction.wait(forDuration: delayPerBall)])
        let repeatSpawn = SKAction.repeat(spawnSequence, count: ballCount)
        
        run(repeatSpawn) { [weak self] in
            self?.run(.sequence([
                .wait(forDuration: 0.5),
                .run { self?.revealNumbers() }
            ]))
        }
    }
    
    private func spawnBall(size: CGFloat) {
        let number = balls.count + 1
        let ball = NumberedBall(number: number, color: .gray, width: size)
        ball.label.isHidden = true
        
        ball.position = CGPoint(
            x: size + .random(in: 0...(self.size.width - 2 * size)),
            y: size + .random(in: 0...(self.size.height - 2 * size))
        )
        
        ball.createPhysicsBody()
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.linearDamping = 0.5    // Increased for smoother movement
        ball.physicsBody?.angularDamping = 0.8   // Increased to reduce spinning
        ball.physicsBody?.restitution = 0.3      // Reduced bounce
        ball.physicsBody?.friction = 0.1         // Reduced friction
        ball.physicsBody?.mass = 0.3             // Increased mass for more stable movement
        
        addChild(ball)
        balls.append(ball)
        
        ActionManager.shared.performAction(.ballAppear)
    }
    
    private func startTimeout() {
        let duration = Double(ballCount) * 0.8  // 0.8 seconds per ball
        
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
    
    private func handleTimeout() {
        isExploding = true
        numbersRevealed = false
        
        // Fade out progress bar
        progressBar.run(.fadeOut(withDuration: 0.3))
        
        // Freeze and fade all balls
        let freezeAction = SKAction.group([
            .fadeAlpha(to: 0.4, duration: 0.3),
            .colorize(with: .gray, colorBlendFactor: 1.0, duration: 0.3)
        ])
        
        for ball in balls {
            ball.run(freezeAction)
        }
        
        onMistake?(mistakesInCurrentRound)  // Report mistakes before cleanup
        
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
    
    private func revealNumbers() {
        balls.forEach { $0.label.isHidden = false }
        numbersRevealed = true
        startTimeout()  // Start timeout when numbers are revealed
    }
    
    private func calculateBallSize(numberOfBalls: Int) -> CGFloat {
        let screenArea = size.width * size.height
        let totalBallArea = screenArea * 0.5
        let ballArea = totalBallArea / CGFloat(numberOfBalls)
        return sqrt(ballArea / .pi) * 2 * 0.8
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard numbersRevealed, !isExploding else { return false }
        
        if let ballNode = nodes(at: location).first(where: { $0 is NumberedBall }) as? NumberedBall {
            if ballNode.isCollected || ballNode.isShowingError { return false }
            
            if ballNode.number == currentNumber {
                ballNode.collect()
                currentNumber += 1
                onBallCollected?()
                ActionManager.shared.performAction(.itemCollected)
                
                if currentNumber > ballCount {
                    handleSuccess()
                    return true
                }
            } else {
                ballNode.showError()
                mistakesInCurrentRound += 1
                onMistake?(mistakesInCurrentRound)
                ActionManager.shared.performAction(.error)
            }
        }
        return false
    }
    
    private func handleSuccess() {
        isExploding = true
        numbersRevealed = false
        
        // Winning animation
        for (index, ball) in balls.enumerated() {
            let delay = Double(index) * 0.1
            ball.run(.sequence([
                .wait(forDuration: delay),
                .group([
                    .scale(to: 1.3, duration: 0.2),
                    .fadeOut(withDuration: 0.2)
                ])
            ])) {
                ball.removeFromParent()
            }
        }
        
        // Remove progress bar
        progressBar.run(.fadeOut(withDuration: 0.3))
        progressBarBackground.run(.fadeOut(withDuration: 0.3))
        
        self.run(.sequence([
            .wait(forDuration: Double(balls.count) * 0.1 + 0.3),
            .run { [weak self] in
                self?.onComplete?()
                self?.removeFromParent()
            }
        ]))
    }
}
