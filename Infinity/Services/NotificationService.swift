import UserNotifications
import UIKit

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    func sendBarkNotification(barkToken: String, title: String, body: String, group: String, icon: String, scheme: String) {
        guard !barkToken.isEmpty else { return }
        
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedIcon = icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(Constants.BarkAPI.baseURL)/\(barkToken)/\(encodedTitle)/\(encodedBody)?group=\(group)&icon=\(encodedIcon)&url=\(scheme)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Bark 通知发送失败: \(error)")
            } else {
                print("Bark 通知发送成功")
            }
        }.resume()
    }
}
