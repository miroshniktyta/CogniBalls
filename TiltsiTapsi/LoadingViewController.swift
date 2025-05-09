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
    private let deepLinkTimeout: TimeInterval = 90.0 // Increased timeout
    private var viewDidLoadTimestamp: Date? // To track time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchAds()
        }
    }
    
    func buildURL() -> URLRequest? {
        print("🔴🔴🔴 LoadingViewController: buildURL called.")
        let deviceId: String? = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv: String? = UIDevice.current.identifierForVendor?.uuidString
        let appsfCuid: String = AppsFlyerLib.shared().getAppsFlyerUID()
        
        print("🔴🔴🔴 LoadingViewController: buildURL - IDFA: \(deviceId ?? "N/A (check ATT status)"), IDFV: \(idfv ?? "N/A"), AppsFlyerUID: \(appsfCuid)")
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cogniballs.com"
        urlComponents.path = "/ads"
        
        var queryItems = [
            URLQueryItem(name: "device_id", value: deviceId),
            URLQueryItem(name: "idfv", value: idfv),
            URLQueryItem(name: "utm_source", value: "fb_iosapp"),
            URLQueryItem(name: "appsf_cuid", value: appsfCuid)
        ]
        
        // Add deep link parameters from UserDefaults if available
        let deepLinkMapping: [(queryParam: String, userDefaultsKey: String)] = [
            ("team_id", "deep_link_value"),
            ("url_path", "deep_link_sub1"),
            ("c", "deep_link_sub2"),
            ("af_adset", "deep_link_sub3"),
            ("buyer_name", "deep_link_sub4"),
            ("account_id", "deep_link_sub5"),
            ("fb_pixel", "deep_link_sub6"),
            ("custom_sub_1", "deep_link_sub7"),
            ("custom_sub_2", "deep_link_sub8"),
            ("custom_sub_3", "deep_link_sub9"),
            ("custom_sub_4", "deep_link_sub10")
        ]
        
        for (queryParam, userDefaultsKey) in deepLinkMapping {
            if let value = UserDefaults.standard.string(forKey: userDefaultsKey), !value.isEmpty {
                queryItems.append(URLQueryItem(name: queryParam, value: value))
            }
        }
        
        queryItems = queryItems.compactMap { $0.value == nil ? nil : $0 }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("🔴🔴🔴 LoadingViewController: buildURL - urlComponents.url is nil. Query items: \(queryItems)")
            return nil
        }
        var request = URLRequest(url: url)
        let userAg = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1" // Placeholder
        request.setValue(userAg, forHTTPHeaderField: "User-Agent")
        print("🔴🔴🔴 LoadingViewController: buildURL successfully created request for URL: \(url.absoluteString)")
        return request
    }
    
    func fetchAds() {
        print("🔴🔴🔴 LoadingViewController: fetchAds called.")
        guard var request = buildURL() else {
            print("🔴🔴🔴 LoadingViewController: fetchAds - buildURL returned nil. Opening tab.")
            DispatchQueue.main.async { self.openTab() } // Ensure UI on main
            return
        }
        request.timeoutInterval = 15.0
        print("🔴🔴🔴 LoadingViewController: fetchAds - Requesting ads from URL: \(request.url?.absoluteString ?? "Invalid URL")")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil) // Renamed for clarity
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { // Perform all completion logic on main thread
                if let error = error {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Error fetching ads: \(error.localizedDescription). Opening tab.")
                    self.openTab()
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Received HTTP status: \(httpResponse.statusCode)")
                }

                if let finalRedirectURL = self.finalRedirectURL { // This implies URLSessionDelegate redirect handling
                    print("🔴🔴🔴 LoadingViewController: fetchAds - finalRedirectURL is set: \(finalRedirectURL). Opening URL.")
                    self.openURL(finalRedirectURL)
                    return
                }
                
                guard let data = data else {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - No data received. Opening tab.")
                    self.openTab()
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Raw response string: \(responseString)")
                } else {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Could not convert data to UTF8 string.")
                }
                            
                do {
                    let adsData = try JSONDecoder().decode([String: [Ad]].self, from: data)
                    let ads = adsData["ad_list"] ?? []
                    // AdManager.ads = ads // Make sure AdManager and Ad struct are defined
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Successfully decoded \(ads.count) ads. Opening tab.")
                    self.openTab()
                } catch {
                    print("🔴🔴🔴 LoadingViewController: fetchAds - Error decoding ads JSON: \(error.localizedDescription). Response data might be: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data"). Opening tab.")
                    self.openTab()
                }
            }
        }
        task.resume()
    }
    
    func openTab() {
        print("🔴🔴🔴 LoadingViewController: openTab called. Presenting GameViewController.")
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "game")
        root.modalTransitionStyle = .crossDissolve
        root.modalPresentationStyle = .fullScreen
        self.present(root, animated: true)
    }
    
    func openURL(_ url: URL) {
        print("🔴🔴🔴 LoadingViewController: openURL called with \(url.absoluteString). Presenting AdWebViewController.")
        let vc = AdWebViewController(adUrl: url.absoluteString) // Ensure AdWebViewController is defined
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension LoadingViewController: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("🔴🔴🔴 LoadingViewController: URLSessionTaskDelegate - willPerformHTTPRedirection to \(request.url?.absoluteString ?? "N/A")")
        if request.url?.absoluteString.contains("tid=") ?? false || request.url?.absoluteString.contains("tkn=") ?? false { // Your specific redirect condition
            self.finalRedirectURL = request.url
            completionHandler (nil) // Stop redirection
        } else {
            completionHandler(request) // Continue redirection
        }
    }
}
