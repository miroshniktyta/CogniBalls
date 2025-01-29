import SpriteKit

class SettingsButtonNode: SKNode {
    private let label: AppLabelNode
    var isEnabled = true {
        didSet {
            updateAppearance()
        }
    }
    
    init(text: String, color: UIColor = .white, fontSize: CGFloat = 24) {
        label = AppLabelNode(text: text)
        label.fontSize = fontSize
        label.fontColor = color
        
        super.init()
        
//        isUserInteractionEnabled = true
        addChild(label)
        
        // Add invisible background for better hit testing
        let bounds = label.calculateAccumulatedFrame()
        let hitArea = SKShapeNode(rectOf: CGSize(
            width: bounds.width + 40,  // Add some padding
            height: bounds.height + 20
        ))
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        addChild(hitArea)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateText(_ text: String) {
        label.text = text
    }
    
    private func updateAppearance() {
        label.fontColor = isEnabled ? .systemGreen : .systemGray
    }
//    
//    // Improve hit testing
//    override func contains(_ p: CGPoint) -> Bool {
//        let bounds = calculateAccumulatedFrame()
//        return bounds.contains(p)
//    }
} 
