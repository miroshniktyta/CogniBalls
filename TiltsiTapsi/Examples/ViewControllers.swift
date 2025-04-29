import UIKit
@preconcurrency import WebKit

class WebViewVC: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!
    private var toolbar: UIToolbar!
    private var leftBarButton: UIBarButtonItem!
    private var rightBarButton: UIBarButtonItem!
    private var url: URL?

    static func instantiate(with url: URL) -> WebViewVC {
        let viewController = WebViewVC()
        viewController.url = url
        return viewController
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    override var shouldAutorotate: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolBar()
        setupWebView()
        loadURL()
        setupNavController()
        print("DEBUG1", self)
    }

    private func setupNavController() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsLinkPreview = true
        view.addSubview(webView)
        setupWebViewConstraints()
    }

    private func setupWebViewConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func setupToolBar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .black
        toolbar.tintColor = .white
        leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(leftBarButtonPressed))
        rightBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(rightBarButtonPressed))
        toolbar.items = [leftBarButton, .flexibleSpace(), rightBarButton]
        view.addSubview(toolbar)
        setupToolbarConstraints()
    }

    private func setupToolbarConstraints() {
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func loadURL() {
        if let url = url { webView.load(URLRequest(url: url)) }
    }

    @objc private func leftBarButtonPressed() {
        if webView.canGoBack { webView.goBack() }
    }

    @objc private func rightBarButtonPressed() {
        if webView.canGoForward { webView.goForward() }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme != "http", url.scheme != "https" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let newVC = WebViewVC.instantiate(with: navigationAction.request.url!)
        present(newVC, animated: true)
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        showAlert(withTitle: "Alert", message: message, completionHandler: completionHandler)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        showConfirmation(withTitle: "Confirm", message: message, completionHandler: completionHandler)
    }

    private func showAlert(withTitle title: String, message: String, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler() }))
        present(alertController, animated: true)
    }

    private func showConfirmation(withTitle title: String, message: String, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler(true) }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler(false) }))
        present(alertController, animated: true)
    }
}

class LoaderVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        print("DEBUG1", self)
    }
}

class BlankVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        print("DEBUG1", self)
    }
}
