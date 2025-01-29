import SpriteKit

class SpacialMemoryBall: SKShapeNode {
    var isCollected = false
    
    var color: UIColor {
        didSet {
            self.fillColor = color.withAlphaComponent(0.5)
            self.strokeColor = color
        }
    }
    
    init(color: UIColor, width: CGFloat) {
        self.color = color

        
        super.init()
        
        // Create the circle path
        let radius = width / 2
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: width, height: width), transform: nil)
        
        // Apply color properties
        self.fillColor = color.withAlphaComponent(0.5)
        self.strokeColor = color
        self.lineWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showAsTarget() {
        color = .systemBlue
    }
    
    func hideTarget() {
        color = .systemGray
    }
    
    func collect() {
        isCollected = true
        color = .systemBlue
    }
    
    func showError() {
        color = .systemRed
        
        run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                guard let self = self else { return }
                self.color = .systemGray
            }
        ]))
    }
    
    func createPhysicsBody() {
        let radius = self.frame.width / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.friction = 0.3
        self.physicsBody?.restitution = 0.6
        self.physicsBody?.allowsRotation = false
    }
} 
