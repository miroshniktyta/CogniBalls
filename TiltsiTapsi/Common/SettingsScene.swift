import SpriteKit

class SettingsScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupUI()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = AppLabelNode(text: "Settings")
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 100)
        addChild(titleLabel)
        
        // Sound Toggle Button
        let soundText = SoundManager.shared.isSoundEnabled ? "Sound: ON 🔊" : "Sound: OFF 🔈"
        let soundButton = SettingsButtonNode(text: soundText)
        soundButton.isEnabled = SoundManager.shared.isSoundEnabled
        soundButton.position = CGPoint(x: frame.midX, y: frame.height - 200)
        soundButton.name = "soundButton"
        addChild(soundButton)
        
        // Vibration Toggle Button
        let vibrationText = VibrationManager.shared.isVibrationEnabled ? "Vibration: ON 📳" : "Vibration: OFF 📴"
        let vibrationButton = SettingsButtonNode(text: vibrationText)
        vibrationButton.isEnabled = VibrationManager.shared.isVibrationEnabled
        vibrationButton.position = CGPoint(x: frame.midX, y: frame.height - 280)
        vibrationButton.name = "vibrationButton"
        addChild(vibrationButton)
        
        // Game Center Button
        let gameCenterButton = SettingsButtonNode(text: "Game Center 🏆", color: .systemBlue)
        gameCenterButton.position = CGPoint(x: frame.midX, y: frame.height - 360)
        gameCenterButton.name = "gameCenterButton"
        addChild(gameCenterButton)
        
        // Back Button
        let backButton = SettingsButtonNode(text: "Back to Menu", color: .systemGray)
        backButton.position = CGPoint(x: frame.midX, y: frame.height - 440)
        backButton.name = "backButton"
        addChild(backButton)
        
        // Fade in animation for all nodes
        children.forEach { node in
            node.alpha = 0
            node.run(.fadeIn(withDuration: 0.3))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            switch node.name {
            case "soundButton":
                toggleSound()
            case "vibrationButton":
                toggleVibration()
            case "gameCenterButton":
                if let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
                    GameCenterManager.shared.showGameCenter(from: viewController)
                }
            case "backButton":
                let menuScene = MenuScene(size: size)
                view?.presentScene(menuScene, transition: .fade(withDuration: 0.3))
            default:
                break
            }
        }
    }
    
    private func toggleSound() {
        SoundManager.shared.isSoundEnabled.toggle()
        guard let button = childNode(withName: "soundButton") as? SettingsButtonNode else { return }
        
        let isEnabled = SoundManager.shared.isSoundEnabled
        button.isEnabled = isEnabled
        button.updateText(isEnabled ? "Sound: ON 🔊" : "Sound: OFF 🔈")
        
        if isEnabled {
            ActionManager.shared.performAction(.buttonTap)
        }
    }
    
    private func toggleVibration() {
        VibrationManager.shared.isVibrationEnabled.toggle()
        guard let button = childNode(withName: "vibrationButton") as? SettingsButtonNode else { return }
        
        let isEnabled = VibrationManager.shared.isVibrationEnabled
        button.isEnabled = isEnabled
        button.updateText(isEnabled ? "Vibration: ON 📳" : "Vibration: OFF 📴")
        
        if isEnabled {
            ActionManager.shared.performAction(.buttonTap)
        }
    }
} 
