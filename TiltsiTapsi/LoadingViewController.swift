//
//  LoadingViewController.swift
//  CogniBalls
//
//  Created by pc on 29.04.25.
//

import UIKit
import WebKit
import AppsFlyerLib
import AdSupport

class LoadingViewController: UIViewController {
    
    var finalRedirectURL: URL?
    private var isWaitingForDeepLink = true
    private let deepLinkTimeout: TimeInterval = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        AppsFlyerManager.shared.initialize()
        NotificationCenter.default.addObserver(self, selector: #selector(deepLinkDataReceived), name: .deepLinkDataReceived, object: nil)
        
        // Start a timer to fetch ads if deep link data doesn't arrive
        DispatchQueue.main.asyncAfter(deadline: .now() + deepLinkTimeout) { [weak self] in
            guard let self = self, self.isWaitingForDeepLink else { return }
            print("🔴🔴🔴 deepLinkTimeout reached")
            self.isWaitingForDeepLink = false
            self.fetchAds()
        }
    }
    
    @objc private func deepLinkDataReceived() {
        guard isWaitingForDeepLink else { return }
        isWaitingForDeepLink = false
        fetchAds()
    }
    
    func buildURL() -> URLRequest? {
        let deviceId: String? = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv: String? = UIDevice.current.identifierForVendor?.uuidString
        let appsfCuid: String = AppsFlyerLib.shared().getAppsFlyerUID()
        
        // Build URL Components
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cogniballs.com"
        urlComponents.path = "/ads"
        
        var queryItems = [
            URLQueryItem(name: "device_id", value: deviceId), // IDFA todo
            URLQueryItem(name: "idfv", value: idfv),
            URLQueryItem(name: "utm_source", value: "fb_iosapp"),
            URLQueryItem(name: "appsf_cuid", value: appsfCuid)
        ]
        
        // Add deep link data if available
        if let deepLinkData = AppsFlyerManager.shared.getDeepLinkData() {
            // Map of your custom parameter names to the deep link keys
            let mapping: [(String, String)] = [
                ("deep_link_value", "team_id"),
                ("deep_link_sub1", "url_path"),
                ("deep_link_sub2", "c"),
                ("deep_link_sub3", "af_adset"),
                ("deep_link_sub4", "buyer_name"),
                ("deep_link_sub5", "account_id"),
                ("deep_link_sub6", "fb_pixel"),
                ("deep_link_sub7", "custom_sub_1"),
                ("deep_link_sub8", "custom_sub_2"),
                ("deep_link_sub9", "custom_sub_3"),
                ("deep_link_sub10", "custom_sub_4")
            ]
            
            for (paramName, deepLinkKey) in mapping {
                if let value = deepLinkData[deepLinkKey] as? String {
                    queryItems.append(URLQueryItem(name: paramName, value: value))
                }
            }
        }
        
        // Remove any nil values
        queryItems = queryItems.compactMap { $0.value == nil ? nil : $0 }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("🔴🔴🔴 urlComponents.url is nil")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(userAg, forHTTPHeaderField: "User-Agent")
        return request
    }
    
    func fetchAds() {
        guard var request = buildURL() else {
            print("🔴🔴🔴 nil from buildURL")
            openTab()
            return
        }
        request.timeoutInterval = 15.0
        print("🔴🔴🔴 Request URL: \(request.url?.absoluteString ?? "🔴🔴🔴 Invalid URL")")
        
        let sessin = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = sessin.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴🔴🔴 Error fetching ads: \(error)")
                DispatchQueue.main.async {
                    self.openTab()
                }
                return
            }
            
            if let finalRedirectURL = self.finalRedirectURL {
                print("🔴🔴🔴 finalRedirectURL is: \(finalRedirectURL)")
                DispatchQueue.main.async {
                    self.openURL(finalRedirectURL)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.openTab()
                }
                return
            }
            
            do {
                let ads = try JSONDecoder().decode([String: [Ad]].self, from: data)["ad_list"] ?? []
                AdManager.ads = ads
                print("🔴🔴🔴 Ads received: \(ads)")
                DispatchQueue.main.async {
                    self.openTab()
                }
            } catch {
                print("🔴🔴🔴 Error decoding ads: \(error)")
                DispatchQueue.main.async {
                    self.openTab()
                }
            }
        }
        
        task.resume()
    }
    
    func openTab() {
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "game")
        root.modalTransitionStyle = .crossDissolve
        root.modalPresentationStyle = .fullScreen
        self.present(root, animated: true)
    }
    
    func openURL(_ url: URL) {
        let vc = AdWebViewController(adUrl: url.absoluteString)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension LoadingViewController: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if request.url?.absoluteString.contains("tid=") ?? false || request.url?.absoluteString.contains("tkn=") ?? false {
            self.finalRedirectURL = request.url
            completionHandler (nil)
        } else {
            completionHandler(request)
        }
    }
}
