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
        // 错误处理代码
    }
}
