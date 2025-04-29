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
    var vc: UIViewController? = nil
    
    func presentAd() {
        guard let ad = AdManager.ads.randomElement() else {
            return
        }
        guard let viewController = vc else {
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
