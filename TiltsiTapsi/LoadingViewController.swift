//
//  LoadingViewController.swift
//  CogniBalls
//
//  Created by pc on 29.04.25.
//

import UIKit
import WebKit

class LoadingViewController: UIViewController {
    
//    let loader = UIActivityIndicatorView(style: .large)
    var finalRedirectURL: URL?

//    var pushToken: String?
//    var campaignId: String?
//    var campaignName: String?
//    var kdId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
//        self.view.addSubview(loader)
//        loader.translatesAutoresizingMaskIntoConstraints = false
//        loader.color = .white
//        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        loader.startAnimating()
        
        fetchAds()
    }

    func buildURL() -> URLRequest? {
//        let deviceId: String? = nil
//        let pushToken = self.pushToken
//        let idfv = UIDevice.current.identifierForVendor?.uuidString
        
        // Build URL Components
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cogniballs.com"
        urlComponents.path = "/ads"
        
        var queryItems = [
//            URLQueryItem(name: "device_id", value: deviceId), // IDFA
//            URLQueryItem(name: "idfv", value: idfv),
            URLQueryItem(name: "utm_source", value: "fb_aosapp"),
//            URLQueryItem(name: "push-token", value: pushToken),
//            URLQueryItem(name: "campaign_id", value: self.campaignId),
//            URLQueryItem(name: "camp_name", value: self.campaignName),
//            URLQueryItem(name: "kd_id", value: self.kdId)
        ]
        
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
