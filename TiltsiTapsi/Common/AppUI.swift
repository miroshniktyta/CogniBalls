import SpriteKit

class AppUI {
    static func createTitle(_ text: String, at position: CGPoint) -> AppLabelNode {
        let titleLabel = AppLabelNode(text: text)
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .bottom
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = position
        return titleLabel
    }
    
    static func createInfoText(_ text: String, at position: CGPoint, width: CGFloat? = nil) -> AppLabelNode {
        let textLabel = AppLabelNode(text: text)
        textLabel.fontSize = 18
        textLabel.fontColor = .white
        textLabel.numberOfLines = 0
        if let width = width {
            textLabel.preferredMaxLayoutWidth = width
        }
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.position = position
        return textLabel
    }
    
    static func createTapLabel(text: String = "Tap to continue", at position: CGPoint) -> AppLabelNode {
        let tapLabel = AppLabelNode(text: text)
        tapLabel.fontSize = 16
        tapLabel.fontColor = .systemGray
        tapLabel.verticalAlignmentMode = .top
        tapLabel.horizontalAlignmentMode = .center
        tapLabel.position = position
        
        // Standard animation
        tapLabel.run(.repeatForever(.sequence([
            .scale(by: 1.2, duration: 0.8),
            .scale(to: 1, duration: 0.7)
        ])))
        
        return tapLabel
    }
    
    static func fadeIn(_ nodes: [SKNode], duration: TimeInterval = 0.3) {
        nodes.forEach { node in
            node.alpha = 0
            node.run(.fadeIn(withDuration: duration))
        }
    }
} 