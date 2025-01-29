//
//  GameScene.swift
//  game
//
//  Created by pc on 02.09.24.
//

import SpriteKit
import GameplayKit
import CoreMotion
import SpriteKit

class SpatialMemoryScene: BaseGameScene {
    // MARK: - Properties
    private let navBarHeight: CGFloat = 48
    private var gameTimer: TimeInterval = 0
    private lazy var lives: Int = maxLives {
        didSet {
            navigationBar?.updateLives(lives, max: maxLives)
            if lives <= 0 {
                gameNode?.removeFromParent()
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
    private var gameNode: SpatialMemoryGameNode?
    private var stepsLabel: AppLabelNode!
    private var livesLabel: AppLabelNode!
    private var tapToStartLabel = AppLabelNode(text: "Tap to Start")
    private var infoLabel: AppLabelNode!
    
    // Timer Management
    private var isTimerActive = false
    private var roundStartTime: TimeInterval = 0
    private var accumulatedTime: TimeInterval = 0
    
    private let bestScoreKey = "BestScoreSpatialMemory"
    private var totalBallsCollected = 0
    
    // Add property to track balls collected in current round
    private var currentRoundBallsCollected = 0
    
    private var navigationBar: GameNavigationBar!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysics()
        setupNavigation()
        setupTapToStartLabel()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        let extendedFrame = CGRect(x: frame.minX, y: frame.minY,
                                 width: frame.width,
                                 height: frame.height - navBarHeight - 16)  // Extra space for progress bar
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
    private func startNextStep() {
        gameNode?.removeFromParent()
        isTimerActive = false
        accumulatedTime = gameTimer
        currentRoundBallsCollected = 0
        
        let ballCount = startingBallCount + currentStep
        let node = SpatialMemoryGameNode(ballCount: ballCount, size: size)
        
        node.onComplete = { [weak self] in
            guard let self = self else { return }
            self.totalBallsCollected += self.currentRoundBallsCollected
            self.currentStep += 1
            self.startNextStep()
        }
        
        node.onBallCollected = { [weak self] in
            self?.currentRoundBallsCollected += 1
        }
        
        node.onMistake = { [weak self] in
            guard let self = self else { return }
            self.totalBallsCollected += self.currentRoundBallsCollected
            self.lives -= 1
            if self.lives > 0 {
                self.startNextStep()
            }
        }
        
        addChild(node)
        gameNode = node
    }
    
    // MARK: - Scene Navigation
    private func calculateScore() -> Int {
        return totalBallsCollected * 10
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
    
    func showFinalScore() {
        let score = calculateScore()
        
        showFinalScore(
            score: score,
            bestScoreKey: bestScoreKey,
            infoLines: [
                "Rounds completed: \(currentStep)",
                "Total balls collected: \(totalBallsCollected)"
            ]
        )
    }
    
    func transitionBackToMenu() {
        view?.presentScene(MenuScene(size: self.size))
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        if let gameNode = gameNode, gameNode.numbersRevealed {
            if !isTimerActive {
                roundStartTime = CACurrentMediaTime()
                isTimerActive = true
            }
            gameTimer = accumulatedTime + (CACurrentMediaTime() - roundStartTime)
        } else {
            isTimerActive = false
        }
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
    
    func setupTapToStartLabel() {
        infoLabel = AppLabelNode(text: "Remember the blue circles\nThen tap them in any order")
        infoLabel.numberOfLines = 0
        infoLabel.fontSize = 18
        infoLabel.fontColor = .white
        infoLabel.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        addChild(infoLabel)
        
        tapToStartLabel.fontSize = 18
        tapToStartLabel.verticalAlignmentMode = .top
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 40)
        addChild(tapToStartLabel)
        tapToStartLabel.run(.repeatForever(.sequence([.scale(by: 1.2, duration: 0.8), .scale(to: 1, duration: 0.7)])))
    }
}
