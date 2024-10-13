import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    func fetchUserInfo() {
        Task {
            do {
                let userID = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
                let fetchedUser: User = try await APIService.shared.fetch("\(Constants.APIEndpoints.users)/\(userID)")
                self.user = fetchedUser
            } catch let error as APIError {
                switch error {
                case .invalidURL:
                    self.errorMessage = "无效的URL"
                case .noData:
                    self.errorMessage = "服务器没有返回数据"
                case .decodingError:
                    self.errorMessage = "数据解码失败"
                case .encodingError:
                    self.errorMessage = "数据编码失败"
                case .networkError(let underlyingError):
                    self.errorMessage = "网络错误: \(underlyingError.localizedDescription)"
                case .httpError(let statusCode):
                    self.errorMessage = "HTTP错误: 状态码 \(statusCode)"
                }
                print("获取用户信息错误: \(self.errorMessage ?? "未知错误")")
            }
        }
    }

    func updateUserInfo(_ updatedUser: User) {
        // 实现更新用户信息的逻辑
    }

    func logout() {
        // 实现登出逻辑
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userID)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.username)
    }
}
