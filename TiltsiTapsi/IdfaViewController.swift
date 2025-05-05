//
//  IdfaViewController.swift
//  AviaMistFighter
//
//  Created by pc on 26.07.24.
//

import UIKit
import AppTrackingTransparency

class IdfaViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func go(_ sender: Any) {
        requestIDFAPermission()
    }
    
    func requestIDFAPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("IDFA authorized: :)")
            case .denied, .restricted, .notDetermined:
                print("IDFA not authorized")
            @unknown default:
                break
            }
            DispatchQueue.main.async {
                self.openLoading()
            }
        }
    }
    
    func openLoading() {
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loading")
        root.modalTransitionStyle = .crossDissolve
        root.modalPresentationStyle = .fullScreen
        self.present(root, animated: true)
    }
}
