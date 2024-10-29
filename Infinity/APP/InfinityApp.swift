import SwiftUI
import UserNotifications

@main
struct InfinityApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        handleURLScheme(url)
        return true
    }
    
    private func handleURLScheme(_ url: URL) {
        guard url.scheme == "infinity" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let path = url.host
        
        switch path {
        case "post":
            if let postId = components?.queryItems?.first(where: { $0.name == "id" })?.value,
               let id = Int(postId) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ShowPost"),
                    object: nil,
                    userInfo: ["postId": id]
                )
            }
        default:
            break
        }
    }
}
