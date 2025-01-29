//
//  AppDelegate.swift
//  TiltsiTapsi
//
//  Created by pc on 24.10.24.
//

import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

extension SKScene {
    func viewController() -> UIViewController? {
        return self.view?.window?.rootViewController
    }
}

extension SKTexture {
    static func fromSymbol(systemName: String, pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        if let symbolImage = UIImage(systemName: systemName, withConfiguration: config) {
            return SKTexture(image: symbolImage)
        }
        return nil
    }
}

class AppLabelNode: SKLabelNode {
    init(text: String) {
        super.init()
        self.text = text
        self.fontName = "Baloo-Regular"
        self.fontSize = 24
        self.fontColor = .white  // Set your custom font color
        self.verticalAlignmentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's background color to black
        self.view.backgroundColor = .black
        
        // Create an SKView
        let skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add SKView to the ViewController's view
        self.view.addSubview(skView)
        
        // Constrain SKView to fill the safe area
        NSLayoutConstraint.activate([
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        // Store reference to skView for later use
        self.skView = skView
    }
    
    private var skView: SKView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let skView = self.skView else { return }
        
        if skView.scene == nil {
            let scene = MenuScene(size: skView.frame.size)
            scene.scaleMode = .resizeFill
//            skView.showsPhysics = false
            skView.presentScene(scene)
//            skView.showsPhysics = true
        }
        
        GameCenterManager.shared.authenticatePlayer(from: self)
    }
}
