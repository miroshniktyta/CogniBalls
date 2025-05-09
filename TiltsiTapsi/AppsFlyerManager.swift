//import UIKit
//import AppsFlyerLib
//
//class AppsFlyerManager: NSObject {
//    static let shared = AppsFlyerManager()
//    
//    private override init() {
//        super.init()
//        if let saved = UserDefaults.standard.dictionary(forKey: deepLinkDataKey) {
//            deepLinkData = saved
//        }
//    }
//    
//    func initialize() {
//        AppsFlyerLib.shared().appsFlyerDevKey = "QNjmhXtbEGkZ5vXbCKiYja" // todo
//        AppsFlyerLib.shared().appleAppID = "6741114445" // todo
//        AppsFlyerLib.shared().delegate = self
//        AppsFlyerLib.shared().start()
//    }
//    
//    private let deepLinkDataKey = "af_lastDeepLinkData"
//    private var deepLinkData: [String: Any]? {
//        didSet {
//            // Save to UserDefaults whenever updated
//            if let data = deepLinkData {
//                UserDefaults.standard.set(data, forKey: deepLinkDataKey)
//            }
//        }
//    }
//    
//    // Getter for deep link data
//    func getDeepLinkData() -> [String: Any]? {
//        return deepLinkData
//    }
//}
//
//extension AppsFlyerManager: AppsFlyerLibDelegate {
//    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
//        print("Conversion data success: \(conversionInfo)")
//    }
//    
//    func onConversionDataFail(_ error: Error) {
//        print("Conversion data fail: \(error)")
//    }
//    
//    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
//        print("App open attribution: \(attributionData)")
//    }
//    
//    func onAppOpenAttributionFailure(_ error: Error) {
//        print("App open attribution failure: \(error)")
//    }
//        
//    func didResolveDeepLink(_ result: DeepLinkResult) {
//        print("Deep link result from didResolveDeepLink: \(result)")
//        dealWithDeepLinkResult(deepLinkResult: result)
//    }
//    
////    func onDeepLinking(_ deepLinkResult: DeepLinkResult) {
////        print("Deep link result from onDeepLinking: \(deepLinkResult)")
////        dealWithDeepLinkResult(deepLinkResult: deepLinkResult)
////    }
//    
//    func dealWithDeepLinkResult(deepLinkResult: DeepLinkResult) {
//        switch deepLinkResult.status {
//        case .found:
//            if let deepLink = deepLinkResult.deepLink {
//                // Store deep link data
//                deepLinkData = deepLink.clickEvent
//                
//                // Notify that deep link data is available
//                NotificationCenter.default.post(name: .deepLinkDataReceived, object: nil)
//            }
//        case .notFound:
//            print("Deep link not found")
//        case .failure:
//            print("Deep link failure")
//        @unknown default:
//            print("Unknown deep link status")
//        }
//    }
//}
//
//// Notification name for deep link data
//extension Notification.Name {
//    static let deepLinkDataReceived = Notification.Name("deepLinkDataReceived")
//}
