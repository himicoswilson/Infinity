import Foundation
import SwiftUI
import UIKit

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var entities: [Entity] = []
    @Published var selectedEntities: Set<Int> = []
    @Published var isAllSelected: Bool = false
    @Published var selectedLocation: Location?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var postCreated: Bool = false
    @Published var showError: Bool = false

    private let maxImageCount = 20

    var onPostCreated: (() -> Void)?

    init(entities: [EntityDTO], onPostCreated: @escaping () -> Void) {
        self.entities = entities.map(convertToEntity)
        self.onPostCreated = onPostCreated
    }
    
    func addImages(_ images: [UIImage]) {
        let remainingSlots = maxImageCount - selectedImages.count
        let imagesToAdd = Array(images.prefix(remainingSlots))
        selectedImages.append(contentsOf: imagesToAdd)
    }
    
    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
    
    var allEntitiesSelected: Bool {
        selectedEntities.count == entities.count && !entities.isEmpty
    }
    
    func toggleEntitySelection(_ entityId: Int) {
        if selectedEntities.contains(entityId) {
            selectedEntities.remove(entityId)
        } else {
            selectedEntities.insert(entityId)
        }
        isAllSelected = allEntitiesSelected
    }
    
    func toggleAllSelection() {
        isAllSelected.toggle()
        if isAllSelected {
            selectedEntities = Set(entities.map { $0.id })
        } else {
            selectedEntities.removeAll()
        }
    }

    func refreshEntities(_ entities: [EntityDTO]) {
        self.entities = entities.map(convertToEntity)
    }
    
    private func convertToEntity(_ entityDTO: EntityDTO) -> Entity {
        return Entity(
            entityID: entityDTO.entityID,
            entityName: entityDTO.entityName,
            entityType: entityDTO.entityType,
            avatar: entityDTO.avatar,
            coupleID: entityDTO.coupleID
        )
    }
    
    var canPost: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }
    
    func createPost() {
        Task {
            isLoading = true
            showError = false
            
            do {
                let entitiesData = selectedEntities.map { ["entityID": $0] }
                let locationData: [String: Any]? = selectedLocation.map { [
                    "latitude": $0.latitude,
                    "longitude": $0.longitude,
                    "locationName": $0.locationName
                ] }

                var files: [String: Data] = [:]
                let fileNames: [String: String] = [:]
                let mimeTypes: [String: String] = [:]
                
                for (index, image) in selectedImages.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        files["image\(index)"] = imageData
                    }
                }
                
                var parameters: [String: Any] = [
                    "content": content,
                    "entities": entitiesData
                ]
                
                if let locationData = locationData {
                    parameters["location"] = locationData
                }
                
                let _: EmptyResponse = try await APIService.shared.upload(
                    Constants.APIEndpoints.posts,
                    method: .post,
                    parameters: parameters,
                    files: files,
                    fileNames: fileNames,
                    mimeTypes: mimeTypes,
                    fileFieldName: "images"
                )

                // 发送通知
                let notificationBody = content.isEmpty ? 
                    (selectedImages.isEmpty ? "" : "[图片]") : 
                    (selectedImages.isEmpty ? content : "\(content)[图片]")
                NotificationService.shared.sendBarkNotification(
                    barkToken: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.loverBarkToken) ?? "",
                    title: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.nickName) ?? "有更新啦~",
                    body: notificationBody,
                    group: Constants.BarkAPI.defaultGroup,
                    icon: Constants.BarkAPI.defaultIcon,
                    scheme: Constants.BarkAPI.defaultScheme
                )

                self.postCreated = true
                self.resetState()
                self.onPostCreated?()
            } catch {
                print("帖子创建失败：\(error)")
                if let apiError = error as? APIError {
                    print("API错误详情：\(apiError)")
                }
                self.errorMessage = APIService.handleError(error)
                self.showError = true
            }
            
            self.isLoading = false
        }
    }
    
    private func resetState() {
        content = ""
        selectedImages = []
        selectedEntities = []
        isAllSelected = false
        errorMessage = nil
    }
}
