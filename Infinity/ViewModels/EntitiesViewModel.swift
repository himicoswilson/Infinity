import Foundation
import SwiftUI

@MainActor
class EntitiesViewModel: ObservableObject {
    @Published var entities: [EntityDTO] = []
    @Published var errorMessage: String?

    func fetchEntities() async {
        do {
            let fetchedEntities: [EntityDTO] = try await APIService.shared.get(Constants.APIEndpoints.entities)
            self.entities = fetchedEntities
            self.errorMessage = nil
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        self.errorMessage = APIService.handleError(error)
        print("获取实体错误: \(self.errorMessage ?? "未知错误")")
    }

    func updateEntityViewedStatus(_ entityID: Int) async {
        if let index = entities.firstIndex(where: { $0.entityID == entityID }) {
            entities[index].unviewed = false
        }
        let endpoint = Constants.APIEndpoints.updateLastViewed(entityID)
        do {
            let _: [EmptyResponse] = try await APIService.shared.get(endpoint)
            print("更新实体浏览状态成功")
        } catch {
            print("更新实体浏览状态失败: \(error)")
        }
    }
}
