import Foundation

@MainActor
class CoupleViewModel: ObservableObject {
    @Published var couple: Couple?
    @Published var user1: User?
    @Published var user2: User?
    @Published var errorMessage: String?
    
    func fetchCoupleInfo() {
        Task {
            do {
                let userID = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
                let fetchedCouple: Couple = try await APIService.shared.fetch(Constants.APIEndpoints.coupleInfo + "\(userID)")
                self.couple = fetchedCouple
                
                self.user1 = try await fetchUserInfo(userId: fetchedCouple.userID1)
                self.user2 = try await fetchUserInfo(userId: fetchedCouple.userID2)
                
            } catch let error as APIError {
                handleError(error)
            }
        }
    }
    
    private func fetchUserInfo(userId: Int) async throws -> User {
        return try await APIService.shared.fetch(Constants.APIEndpoints.users + "/\(userId)")
    }
    
    private func handleError(_ error: APIError) {
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
        print("获取信息错误: \(self.errorMessage ?? "未知错误")")
    }

    var currentUser: User {
        let currentUserId = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
        guard currentUserId != 0 else {
            fatalError("当前用户ID不存在")
        }
        return currentUserId == user1?.userID ? user1! : user2!
    }

    var lover: User {
        let currentUserId = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
        guard currentUserId != 0 else {
            fatalError("当前用户ID不存在")
        }
        return currentUserId == user1?.userID ? user2! : user1!
    }
}
