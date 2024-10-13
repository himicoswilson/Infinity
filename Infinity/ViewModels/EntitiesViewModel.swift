import Foundation
import SwiftUI

@MainActor
class EntitiesViewModel: ObservableObject {
    @Published var entities: [EntityDTO] = []
    @Published var errorMessage: String?

    func fetchEntities() {
        Task {
            do {
                let fetchedEntities: [EntityDTO] = try await APIService.shared.fetch(Constants.APIEndpoints.entities)
                self.entities = fetchedEntities
            } catch let error as APIError {
                handleError(error)
            }
        }
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
        print("获取实体错误: \(self.errorMessage ?? "未知错误")")
    }
}
