//
//  AdWebViewController.swift
//  CogniBalls
//
//  Created by pc on 29.04.25.
//

import UIKit
import WebKit

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
