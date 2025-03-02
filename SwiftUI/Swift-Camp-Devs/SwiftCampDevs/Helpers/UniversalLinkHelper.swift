import Foundation
import UIKit

protocol AppLauncherProtocol {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
}
extension UIApplication: AppLauncherProtocol {}

struct UniversalLinkHelper {
    static func openURL(_ urlString: String, application: AppLauncherProtocol = UIApplication.shared) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        application.open(url, options: [:]) { success in
            if !success {
                print("🚫 Cannot open URL: \(urlString)")
            }
        }
    }
}
