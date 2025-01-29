import SpriteKit

class GameNavigationBar: SKShapeNode {
    private let height: CGFloat = 48
    private let width: CGFloat
    private let stepsLabel: AppLabelNode
    private let livesLabel: AppLabelNode
    
    var onBackButtonTap: (() -> Void)?
    
    init(width: CGFloat) {
        self.width = width
        self.stepsLabel = AppLabelNode(text: "0")
        self.livesLabel = AppLabelNode(text: "3/3")
        
        super.init()
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        path = CGPath(rect: rect, transform: nil)
        fillColor = .black
        strokeColor = .clear
        zPosition = 100
        
        setupBackButton()
        setupStepsIndicator()
        setupLivesCounter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackButton() {
        let backButton = SKShapeNode(rectOf: CGSize(width: 40, height: 30), cornerRadius: 5)
        backButton.fillColor = .clear
        backButton.strokeColor = .clear
        backButton.name = "backButton"
        backButton.position = CGPoint(x: 36, y: height/2)
        
        let backArrow = AppLabelNode(text: "<")
        backArrow.fontColor = .white
        backArrow.fontSize = 32
        backArrow.position = CGPoint(x: 0, y: -10)
        backArrow.verticalAlignmentMode = .center
        backButton.addChild(backArrow)
        
        addChild(backButton)
    }
    
    private func setupStepsIndicator() {
        let stepsCaption = AppLabelNode(text: "Round")
        stepsCaption.fontSize = 12
        stepsCaption.fontColor = .systemGray
        stepsCaption.position = CGPoint(x: width/2, y: height - 14)
        addChild(stepsCaption)
        
        stepsLabel.fontSize = 24
        stepsLabel.position = CGPoint(x: width/2, y: height - 34)
        addChild(stepsLabel)
    }
    
    private func setupLivesCounter() {
        let livesCaption = AppLabelNode(text: "Lives")
        livesCaption.fontSize = 12
        livesCaption.fontColor = .systemGray
        livesCaption.position = CGPoint(x: width - 60, y: height - 14)
        addChild(livesCaption)
        
        livesLabel.fontSize = 24
        livesLabel.position = CGPoint(x: width - 60, y: height - 34)
        addChild(livesLabel)
    }
    
    func updateSteps(_ steps: Int) {
        stepsLabel.text = "\(steps)"
    }
    
    func updateLives(_ current: Int, max: Int) {
        livesLabel.text = "\(current)/\(max)"
    }
} 
