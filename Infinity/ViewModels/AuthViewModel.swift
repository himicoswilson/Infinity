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
                let response: LoginResponse = try await APIService.shared.post(Constants.APIEndpoints.login, parameters: loginData)
                
                self.loginSuccessful = true
                self.isAuthenticated = true
                
                Task.detached(priority: .background) {
                    UserDefaults.standard.set(response.token, forKey: Constants.UserDefaultsKeys.token)
                    UserDefaults.standard.set(response.user.userID, forKey: Constants.UserDefaultsKeys.userID)
                    UserDefaults.standard.set(response.user.userName, forKey: Constants.UserDefaultsKeys.username)
                    UserDefaults.standard.set(response.user.nickName, forKey: Constants.UserDefaultsKeys.nickName)
                }
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("登录错误: \(self.errorMessage ?? "未知错误")")
            }
        }
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
                let response: RegisterResponse = try await APIService.shared.post(Constants.APIEndpoints.register, parameters: registerData)
                
                self.isAuthenticated = true
                
                Task.detached(priority: .background) {
                    UserDefaults.standard.set(response.token, forKey: Constants.UserDefaultsKeys.token)
                    UserDefaults.standard.set(response.user.userID, forKey: Constants.UserDefaultsKeys.userID)
                    UserDefaults.standard.set(response.user.userName, forKey: Constants.UserDefaultsKeys.username)
                    UserDefaults.standard.set(response.user.nickName, forKey: Constants.UserDefaultsKeys.nickName)
                }
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("注册错误: \(self.errorMessage ?? "未知错误")")
            }
        }
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
