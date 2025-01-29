//
//  SpatialMemoryGameNode.swift
//  TiltsiTapsi
//
//  Created by pc on 27.01.25.
//

import SpriteKit

class SpatialMemoryGameNode: SKNode {
    var onComplete: (() -> Void)?  // Reports mistakes when round is complete
    var onMistake: (() -> Void)?      // Add this callback
    var onBallCollected: (() -> Void)?  // Add new callback
    var numbersRevealed = false
    
    private var balls = [SpacialMemoryBall]()
    private var targetBalls: Set<SpacialMemoryBall> = []
    private var correctBallsFound = 0
    private var mistakes = 0
    private let ballCount: Int
    private let size: CGSize
    
    private let appearanceDuration: Double = 1.0
    private let targetShowDuration: Double = 1.0
    
    private var isAnimating = false  // Add this to prevent taps during animations
    
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
            .wait(forDuration: 0.5),
            .run { [weak self] in
                self?.selectTargetBalls()
                self?.showTargetBalls()
            }
        ]))
    }
    
    private func spawnBall(size: CGFloat) {
        let ball = SpacialMemoryBall(color: .gray, width: size)
        
        // Position ball with some margin from edges
        let margin: CGFloat = size
        ball.position = CGPoint(
            x: margin + .random(in: 0...(self.size.width - 2*margin)),
            y: margin + .random(in: 0...(self.size.height - 2*margin))
        )
        
        ball.createPhysicsBody()
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.linearDamping = 0.1  // Reduced from 1.0 to make balls float longer
        ball.physicsBody?.angularDamping = 0.1 // Reduced from 1.0
        ball.physicsBody?.restitution = 0.9    // Increased bounce
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.mass = 0.1
        
        addChild(ball)
        balls.append(ball)
        
        ActionManager.shared.performAction(.ballAppear)
    }
    
    private func selectTargetBalls() {
        let targetCount = ballCount / 2
        while targetBalls.count < targetCount {
            if let randomBall = balls.randomElement() {
                targetBalls.insert(randomBall)
            }
        }
    }
    
    private func showTargetBalls() {
        // Show target balls in blue
        targetBalls.forEach { ball in
            ball.showAsTarget()
        }
        
        // Hide them after delay and start the game
        run(.sequence([
            .wait(forDuration: targetShowDuration),
            .run { [weak self] in
                self?.hideBalls()
            }
        ]))
    }
    
    func hideBalls() {
        targetBalls.forEach { $0.hideTarget() }
        numbersRevealed = true
        
        balls.forEach { ball in
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let force = CGFloat.random(in: 4...6)  // Increased force range
            let impulse = CGVector(dx: cos(angle) * force, dy: sin(angle) * force)
            ball.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard numbersRevealed, !isAnimating else { return false }
        
        if let ballNode = nodes(at: location).first(where: { $0 is SpacialMemoryBall }) as? SpacialMemoryBall {
            if ballNode.isCollected { return false }
            
            if targetBalls.contains(ballNode) {
                ballNode.collect()
                correctBallsFound += 1
                onBallCollected?()  // Call new callback
                ActionManager.shared.performAction(.itemCollected)
                
                if correctBallsFound == targetBalls.count {
                    handleSuccess()
                    return true
                }
            } else {
                handleFailure(wrongBall: ballNode)
                ActionManager.shared.performAction(.error)
            }
        }
        return false
    }
    
    private func handleSuccess() {
        numbersRevealed = false
        isAnimating = true
        
        // Remove non-target balls
        balls.forEach { ball in
            if !targetBalls.contains(ball) {
                ball.run(.fadeOut(withDuration: 0.3))
            }
        }
        
        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                guard let self = self else { return }
                self.onComplete?()
            }
        ]))
    }
    
    private func handleFailure(wrongBall: SpacialMemoryBall) {
        numbersRevealed = false
        isAnimating = true
        
        // Show wrong ball in red
        wrongBall.color = .red
        
        // Show all target balls in blue
        targetBalls.forEach { ball in
            if ball != wrongBall {  // Don't change the wrong ball's color
                ball.showAsTarget()
            }
        }
        
        // Fade out all balls
        let fadeOutAction = SKAction.sequence([
            .wait(forDuration: 1.0),  // Show the correct positions for a moment
            .fadeOut(withDuration: 0.3)
        ])
        
        balls.forEach { ball in
            ball.run(fadeOutAction)
        }
        
        // Reset the game after animation
        run(.sequence([
            .wait(forDuration: 1.5),  // Wait for fade out to complete
            .run { [weak self] in
                guard let self = self else { return }
                // Remove all existing balls
                self.balls.forEach { $0.removeFromParent() }
                self.balls.removeAll()
                self.targetBalls.removeAll()
                self.correctBallsFound = 0
                self.isAnimating = false
                
                // Notify about mistake
                self.onMistake?()
                
                // Setup new game with same ball count
                self.setupGame()
            }
        ]))
    }
    
    private func calculateBallSize(numberOfBalls: Int) -> CGFloat {
        let screenArea = size.width * size.height
        let totalBallArea = screenArea * 0.4
        let ballArea = totalBallArea / CGFloat(numberOfBalls)
        return sqrt(ballArea / .pi) * 2
    }
}
