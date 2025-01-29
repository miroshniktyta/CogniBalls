import SpriteKit

class CorsiTappingGameNode: SKNode {
    var onComplete: (() -> Void)?
    var onMistake: ((Int) -> Void)?
    var numbersRevealed = false
    
    private var balls = [CorsiTappingBall]()
    private var sequence: [CorsiTappingBall] = []
    private var currentSequenceIndex = 0
    private var isShowingSequence = false
    private var isInputting = false
    private let ballCount: Int
    private let size: CGSize
    
    private let appearanceDuration: Double = 1.0
    private let showDuration: Double = 0.5
    
    init(ballCount: Int, size: CGSize) {
        self.ballCount = ballCount
        self.size = size
        super.init()
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
            .wait(forDuration: 1.0),
            .run { [weak self] in
                self?.scene?.physicsWorld.gravity = .zero  // Ensure no gravity
                self?.generateAndShowSequence()
            }
        ]))
    }
    
    private func spawnBall(size: CGFloat) {
        let number = balls.count + 1
        let ball = CorsiTappingBall(number: number, color: .gray, width: size)
//        ball.label.isHidden = true
        
        let margin: CGFloat = size
        ball.position = CGPoint(
            x: margin + .random(in: 0...(self.size.width - 2*margin)),
            y: margin + .random(in: 0...(self.size.height - 2*margin))
        )
        
        ball.createPhysicsBody()
        addChild(ball)
        balls.append(ball)
        
        ActionManager.shared.performAction(.ballAppear)
    }
    
    private func generateAndShowSequence() {
        isShowingSequence = true
        sequence = balls.shuffled()
        currentSequenceIndex = 0
        showNextInSequence()
    }
    
    private func showNextInSequence() {
        guard currentSequenceIndex < sequence.count else {
            finishShowingSequence()
            return
        }
        
        let ball = sequence[currentSequenceIndex]
        ball.run(.sequence([
            .run { 
                ball.highlight()
                ball.sequenceNumber = self.currentSequenceIndex + 1
                ball.applyHighlightImpulse()
            },
            .wait(forDuration: showDuration),
            .run {
                ball.unhighlight()
            },
            .wait(forDuration: 0.1),
            .run { [weak self] in
                self?.currentSequenceIndex += 1
                self?.showNextInSequence()
            }
        ]))
    }
    
    private func finishShowingSequence() {
        currentSequenceIndex = 0
        isShowingSequence = false
        isInputting = true
        numbersRevealed = true
        
        // Add some random movement to all balls after sequence
        balls.forEach { ball in
            let randomAngle = CGFloat.random(in: 0...(2 * .pi))
            let randomForce: CGFloat = 10.0
            let impulse = CGVector(
                dx: cos(randomAngle) * randomForce,
                dy: sin(randomAngle) * randomForce
            )
            ball.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard isInputting && !isShowingSequence else { return false }
        
        if let ballNode = nodes(at: location).first(where: { $0 is CorsiTappingBall }) as? CorsiTappingBall {
            if ballNode.isLocked { return false }
            
            if sequence[currentSequenceIndex] == ballNode {
                ballNode.collect()
                currentSequenceIndex += 1
                ActionManager.shared.performAction(.itemCollected)
                
                if currentSequenceIndex >= sequence.count {
                    numbersRevealed = false
                    run(.sequence([
                        .wait(forDuration: 1.0),
                        .run { [weak self] in
                            self?.onComplete?()
                        }
                    ]))
                    return true
                }
            } else {
                handleFailure(wrongBall: ballNode)
                return false
            }
        }
        return false
    }
    
    private func handleFailure(wrongBall: CorsiTappingBall) {
        isInputting = false
        
        wrongBall.showError()
        
        let correctBall = sequence[currentSequenceIndex]
        correctBall.highlight()
        
        let fadeOutAction = SKAction.sequence([
            .wait(forDuration: 0.8),
            .fadeOut(withDuration: 0.3)
        ])
        
        balls.forEach { ball in
            ball.run(fadeOutAction)
        }
        
        run(.sequence([
            .wait(forDuration: 1.2),
            .run { [weak self] in
                guard let self = self else { return }
                self.onMistake?(self.currentSequenceIndex)
                self.removeFromParent()
            }
        ]))
    }
    
    private func calculateBallSize(numberOfBalls: Int) -> CGFloat {
        let screenArea = size.width * size.height
        let totalBallArea = screenArea * 0.4
        let ballArea = totalBallArea / CGFloat(numberOfBalls)
        return sqrt(ballArea / .pi) * 2 * 0.7
    }
} 
