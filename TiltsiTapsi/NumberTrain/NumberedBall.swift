//
//  NumberedBall.swift
//  TiltsiTapsi
//
//  Created by pc on 27.01.25.
//

import SpriteKit

class NumberedBall: SKShapeNode {
    let number: Int
    var isCollected = false
    
    let label: SKLabelNode
    
    var color: UIColor {
        didSet {
            self.fillColor = color.withAlphaComponent(0.5)
            self.strokeColor = color
        }
    }
    
    var isShowingError = false
    
    init(number: Int, color: UIColor, width: CGFloat) {
        self.number = number
        self.color = color
        
        // Create the label first
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.text = "\(number)"
        self.label.fontSize = width * 0.4
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center
        
        super.init()
        
        // Create the circle path
        let radius = width / 2
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: width, height: width), transform: nil)
        
        // Apply color properties
        self.fillColor = color.withAlphaComponent(0.5)
        self.strokeColor = color
        self.lineWidth = 1
        
        // Add the label
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPhysicsBody() {
        let radius = self.frame.width / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.friction = 0.3
        self.physicsBody?.restitution = 0.6
        self.physicsBody?.allowsRotation = false
    }
    
    func collect() {
        isCollected = true
        color = .systemGreen
    }
    
    func showError() {
        guard !isShowingError else { return }
        
        isShowingError = true
        let originalColor = self.color
        self.color = .systemRed
        
        run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                self?.color = originalColor
                self?.isShowingError = false
            }
        ]))
    }
}
