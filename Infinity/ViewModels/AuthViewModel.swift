import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var loginSuccessful = false

    func checkAuthenticationStatus() {
        if UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) != nil {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
    
    func login(username: String, password: String) {
        Task {
            do {
                let loginData = ["username": username, "password": password]
                let response: LoginResponse = try await APIService.shared.post(Constants.APIEndpoints.login, body: loginData)
                
                self.loginSuccessful = true
                // 立即更新认证状态
                self.isAuthenticated = true
                
                // 异步保存 UserDefaults
                Task.detached(priority: .background) {
                    UserDefaults.standard.set(response.token, forKey: Constants.UserDefaultsKeys.token)
                    UserDefaults.standard.set(response.user.userID, forKey: Constants.UserDefaultsKeys.userID)
                    UserDefaults.standard.set(response.user.userName, forKey: Constants.UserDefaultsKeys.username)
                }
            } catch {
                handleLoginError(error)  // 移除了 await
            }
        }
    }
    
    private func handleLoginError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
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
        } else {
            self.errorMessage = "未知错误: \(error.localizedDescription)"
        }
        print("登录错误: \(self.errorMessage ?? "未知错误")")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.token)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userID)
        isAuthenticated = false
    }
    
    func register(username: String, password: String, email: String) {
        Task {
            do {
                let registerData = ["username": username, "password": password, "email": email]
                let response: RegisterResponse = try await APIService.shared.post(Constants.APIEndpoints.register, body: registerData)
                
                // 立即更新认证状态
                self.isAuthenticated = true
                
                // 异步保存 UserDefaults
                Task.detached(priority: .background) {
                    UserDefaults.standard.set(response.token, forKey: Constants.UserDefaultsKeys.token)
                    UserDefaults.standard.set(response.user.userID, forKey: Constants.UserDefaultsKeys.userID)
                    UserDefaults.standard.set(response.user.userName, forKey: Constants.UserDefaultsKeys.username)
                }
            } catch {
                handleRegisterError(error)
            }
        }
    }
    
    private func handleRegisterError(_ error: Error) {
        // 实现类似 handleLoginError 的错误处理逻辑
    }
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct RegisterResponse: Codable {
    let token: String
    let user: User
}
