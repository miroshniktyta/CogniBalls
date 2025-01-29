//
//  SpotScene.swift
//  game
//
//  Created by pc on 04.09.24.
//

import SpriteKit
import CoreMotion

class CorsiTappingScene: BaseGameScene {
    // MARK: - Properties
    private let navBarHeight: CGFloat = 48
    private var navigationBar: GameNavigationBar!
    
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
    private let startingBallCount = 5
    
    // UI Elements
    private var gameNode: CorsiTappingGameNode?
    private var tapToStartLabel = AppLabelNode(text: "Tap to Start")
    private var infoLabel: AppLabelNode!
    
    private let bestScoreKey = "BestScoreCorsiTapping"
    private var totalBallsCollected = 0
    
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
        
        navigationBar.updateLives(lives, max: maxLives)
        navigationBar.updateSteps(currentStep)
    }
    
    private func setupTapToStartLabel() {
        infoLabel = AppLabelNode(text: "Remember the sequence\n   Then repeat it in order")
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
    
    // MARK: - Game Flow
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
    
    private func startNextStep() {
        gameNode?.removeFromParent()
        
        let ballCount = startingBallCount + currentStep
        let node = CorsiTappingGameNode(ballCount: ballCount, size: size)
        
        node.onComplete = { [weak self] in
            guard let self = self else { return }
            self.totalBallsCollected += ballCount  // Count all balls in completed step
            self.currentStep += 1  // Increment only on completion
            self.startNextStep()
        }
        
        node.onMistake = { [weak self] correctCount in
            guard let self = self else { return }
            self.totalBallsCollected += correctCount  // Count correctly tapped balls
            self.lives -= 1
            if self.lives > 0 {
                self.startNextStep()  // Retry same step
            }
        }
        
        addChild(node)
        gameNode = node
    }
    
    func showFinalScore() {
        let score = calculateScore()
        
        showFinalScore(
            score: score,
            bestScoreKey: bestScoreKey,
            infoLines: [
                "Rounds completed: \(currentStep)",
                "Balls collected: \(totalBallsCollected)"
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
        
        if let backButton = nodes(at: location).first(where: { $0.name == "backButton" }) {
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
