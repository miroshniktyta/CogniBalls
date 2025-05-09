//
//  AppDelegate.swift
//  TiltsiTapsi
//
//  Created by pc on 24.10.24.
//

import UIKit
import SpriteKit
import AppsFlyerLib
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let initialViewController: UIViewController
        
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "idfa")
        } else {
            initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loading")
        }
        
        window = UIWindow()
        window?.rootViewController = initialViewController
        
        window?.makeKeyAndVisible()
        initializeAppsFluer()
        
        return true
    }
    
    // Handle deep links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    // Handle URL schemes
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
    
    @objc func appsFluerSendLaunch() {
        AppsFlyerLib.shared().start()
    }

}

extension AppDelegate {
    
    func initializeAppsFluer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "QNjmhXtbEGkZ5vXbCKiYja"
        AppsFlyerLib.shared().appleAppID = "6741114445"
        AppsFlyerLib.shared().customerUserID = AppsFlyerLib.shared().getAppsFlyerUID()
        
        AppsFlyerLib.shared().deepLinkDelegate = self
//        AppsFlyerLib.shared().isDebug = true
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 90)
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("appsFluerSendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

extension AppDelegate: DeepLinkDelegate {
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        var fruitNameStr: String?
        
        switch result.status {
        case .notFound:
            NSLog("[AFSDK] Deep link not found")
            return
        case .failure:
            print("Error %@", result.error!)
            return
        case .found:
            NSLog("[AFSDK] Deep link found")
        }
        
        guard let deepLinkObj:DeepLink = result.deepLink else {
            NSLog("[AFSDK] Could not extract deep link object")
            return
        }
        
        saveDeepLinkParamIfNeeded(key: "deep_link_value", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub1", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub2", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub3", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub4", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub5", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub6", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub7", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub8", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub9", from: deepLinkObj.clickEvent)
        saveDeepLinkParamIfNeeded(key: "deep_link_sub10", from: deepLinkObj.clickEvent)
        
        let deepLinkStr:String = deepLinkObj.toString()
        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
            
        if( deepLinkObj.isDeferred == true) {
            NSLog("[AFSDK] This is a deferred deep link")
        }
        else {
            NSLog("[AFSDK] This is a direct deep link")
        }
        
        fruitNameStr = deepLinkObj.deeplinkValue
    }
    
    private func saveDeepLinkParamIfNeeded(key: String, from dict: [String: Any]) {
        if dict.keys.contains(key) {
            let value = dict[key] as? String
            if let value = value, !value.isEmpty {
                let saved = UserDefaults.standard.string(forKey: key)
                if saved == nil || saved?.isEmpty == true {
                    UserDefaults.standard.setValue(value, forKey: key)
                }
            }
            NSLog("\(key): \(value ?? "nil")")
        } else {
            NSLog("[AFSDK] Could not extract \(key)")
        }
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
            skView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        // Store reference to skView for later use
        self.skView = skView
        AdManager.shared.vc = self
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
