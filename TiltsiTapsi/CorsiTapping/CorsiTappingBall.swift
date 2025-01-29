//
//  SpanBall.swift
//  TiltsiTapsi
//
//  Created by pc on 27.01.25.
//

import SpriteKit

class CorsiTappingBall: SKShapeNode {
    var isCollected = false
    var isLocked = false  // Add this property to prevent double-taps
//    let label: SKLabelNode
    let number: Int
    var sequenceNumber: Int = 0  // Add this property
    
    var color: UIColor {
        didSet {
            self.fillColor = color.withAlphaComponent(0.5)
            self.strokeColor = color
        }
    }
    
    init(number: Int, color: UIColor, width: CGFloat) {
        self.number = number
        self.color = color
        
//        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
//        self.label.text = "\(number)"
//        self.label.fontSize = width * 0.4
//        self.label.fontColor = .white
//        self.label.verticalAlignmentMode = .center
//        self.label.horizontalAlignmentMode = .center
        
        super.init()
        
        let radius = width / 2
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: width, height: width), transform: nil)
        
        self.fillColor = color.withAlphaComponent(0.5)
        self.strokeColor = color
        self.lineWidth = 1
        
//        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPhysicsBody() {
        let radius = self.frame.width / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.friction = 0.2
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.linearDamping = 0.8  // More damping for controlled movement
        self.physicsBody?.angularDamping = 1.0  // Prevent spinning
        self.physicsBody?.mass = 0.3
        self.physicsBody?.allowsRotation = false
    }
    
    func applyHighlightImpulse() {
        // Random direction for more natural movement
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let force: CGFloat = 20.0
        
        let impulse = CGVector(
            dx: cos(angle) * force,
            dy: sin(angle) * force
        )
        
        self.physicsBody?.applyImpulse(impulse)
    }
    
    func collect() {
        isCollected = true
        isLocked = true
        color = .systemGreen
//        label.text = "\(sequenceNumber)"  // Show sequence number instead of original number
//        label.isHidden = false
    }
    
    func showError() {
        isLocked = true  // Lock the ball when showing error
        color = .systemRed
        
        run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                guard let self = self else { return }
                self.color = .systemGray
                self.isLocked = false  // Unlock after error animation
            }
        ]))
    }
    
    func highlight() {
        color = .systemYellow
//        label.isHidden = false
    }
    
    func unhighlight() {
        color = .systemGray
//        label.isHidden = true
    }
}
