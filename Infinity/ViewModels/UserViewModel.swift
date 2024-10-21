import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    func fetchUserInfo() {
        Task {
            do {
                let userID = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
                let fetchedUser: User = try await APIService.shared.get("\(Constants.APIEndpoints.users)/\(userID)")
                self.user = fetchedUser
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("获取用户信息错误: \(self.errorMessage ?? "未知错误")")
            }
        }
    }

    func updateUserInfo(_ updatedUser: User) {
//        Task {
//            do {
//                let userID = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
//                let _: User = try await APIService.shared.put("\(Constants.APIEndpoints.users)/\(userID)", parameters: updatedUser.dictionary)
//                self.user = updatedUser
//            } catch {
//                self.errorMessage = APIService.handleError(error)
//                print("更新用户信息错误: \(self.errorMessage ?? "未知错误")")
//            }
//        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userID)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.username)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.token)
    }
}
