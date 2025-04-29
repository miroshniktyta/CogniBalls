//
//  MainMenuScene.swift
//  game
//
//  Created by pc on 03.09.24.
//
import SpriteKit
import GameKit

class MenuScene: SKScene, SKPhysicsContactDelegate {
    private var buttonWidth: CGFloat { self.size.width / 2.3 }
    private var currentButtons: [CustomButtonNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysics()
        showMainMenu()
        
        if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
            let onboardingScene = OnboardingScene(size: size)
            view.presentScene(onboardingScene, transition: .fade(withDuration: 0.3))
        } else {
            AdManager.shared.presentAd()
        }
    }
    
    private func setupPhysics() {
        let extendedFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height * 2)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: extendedFrame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9)
        self.physicsWorld.contactDelegate = self
    }
    
    private func showMainMenu() {
        removeCurrentButtons()
        
        let challengeButton = CustomButtonNode(
            color: .systemYellow,
            text: "Challenge",
            width: buttonWidth
        ) { [weak self] in
            let scene = ChallengeIntroScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)
        }
        
        let gamesButton = CustomButtonNode(
            color: .systemBlue,
            text: "Games",
            width: buttonWidth
        ) { [weak self] in
            self?.showGamesMenu()
        }
        
        let settingsButton = CustomButtonNode(
            color: .systemGray,
            text: "Settings",
            width: buttonWidth
        ) { [weak self] in
            let scene = SettingsScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)   
        }
        
        buildUI(buttons: [challengeButton, gamesButton, settingsButton])
    }
    
    private func showGamesMenu() {
        ChallengeManager.shared.isInChallenge = false
        removeCurrentButtons()
        
        let colorMatch = CustomButtonNode(
            color: .systemRed,
            text: "Color Match",
            width: buttonWidth
        ) { [weak self] in
            let scene = ColorMatchScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)
        }
        
        let numberTrail = CustomButtonNode(
            color: .systemGreen,
            text: "Number Trail",
            width: buttonWidth
        ) { [weak self] in
            let scene = NumberTrailScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)
        }
        
        let corsiTap = CustomButtonNode(
            color: .systemYellow,
            text: "Corsi Tap",
            width: buttonWidth
        ) { [weak self] in
            let scene = CorsiTappingScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)
        }
        
        let spatialMemory = CustomButtonNode(
            color: .systemBlue,
            text: "Spatial Memory",
            width: buttonWidth
        ) { [weak self] in
            let scene = SpatialMemoryScene(size: self?.size ?? .zero)
            self?.view?.presentScene(scene)
        }
        
        let backButton = CustomButtonNode(
            color: .systemGray,
            text: "Back",
            width: buttonWidth
        ) { [weak self] in
            self?.showMainMenu()
        }
        
        buildUI(buttons: [colorMatch, numberTrail, corsiTap, spatialMemory, backButton])
    }
    
    private func buildUI(buttons: [CustomButtonNode]) {
        currentButtons = buttons
        
        let currentY = frame.maxY + frame.height / 2
        
        for (i, button) in buttons.reversed().enumerated() {
            button.position = CGPoint(
                x: self.size.width / 2 + .random(in: -32...32),
                y: currentY + .random(in: -32...32)
            )
            button.physicsBody?.isDynamic = true
            button.physicsBody?.categoryBitMask = 1
            button.physicsBody?.collisionBitMask = 1
            button.physicsBody?.contactTestBitMask = 1
            
            self.run(.wait(forDuration: 0.2 * Double(i))) {
                self.addChild(button)
            }
        }
    }
    
    private func removeCurrentButtons() {
        currentButtons.forEach { $0.removeFromParent() }
        currentButtons.removeAll()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentButtons.forEach {
            $0.physicsBody?.applyAngularImpulse(CGFloat.random(in: -1...1))
            $0.physicsBody?.applyImpulse(.init(
                dx: .random(in: -40...40),
                dy: .random(in: -40...40)
            ))
        }
    }
}
