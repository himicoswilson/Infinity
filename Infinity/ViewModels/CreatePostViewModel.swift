import Foundation
import SwiftUI
import UIKit

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var entities: [Entity] = []
    @Published var selectedEntities: [Int] = []
    @Published var isAllSelected: Bool = false
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
    
    func toggleEntitySelection(_ entityId: Int) {
        if selectedEntities.contains(entityId) {
            selectedEntities.removeAll { $0 == entityId }
            isAllSelected = false
        } else {
            selectedEntities.append(entityId)
        }
    }
    
    func toggleAllSelection() {
        isAllSelected.toggle()
        if isAllSelected {
            selectedEntities = entities.map { $0.id }
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
    
    func createPost() {
        isLoading = true
        showError = false
        
        guard let url = URL(string: Constants.APIEndpoints.posts) else {
            self.errorMessage = "无效的URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 添加token到请求头
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("无法获取token")
            return
        }

        var body = Data()
        
        // 添加内容
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"content\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(content)\r\n".data(using: .utf8)!)
        
        // 添加标签
//        let tags = [["tagID": 1], ["tagID": 2]] // 示例标签，需要根据实际情况修改
//        let tagsData = try? JSONEncoder().encode(tags)
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"tags\"\r\n\r\n".data(using: .utf8)!)
//        body.append(tagsData ?? Data())
//        body.append("\r\n".data(using: .utf8)!)
        
        // 添加实体
        let entitiesData = selectedEntities.map { ["entityID": $0] }
        let entitiesJSONData = try? JSONEncoder().encode(entitiesData)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"entities\"\r\n\r\n".data(using: .utf8)!)
        body.append(entitiesJSONData ?? Data())
        body.append("\r\n".data(using: .utf8)!)
        
        // 添加图片
        for (index, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "网络错误: \(error.localizedDescription)"
                    self.showError = true
                    print("网络请求错误: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "无效的响应"
                    self.showError = true
                    print("无效的响应: \(String(describing: response))")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "服务器错误: \(httpResponse.statusCode)"
                    self.showError = true
                    print("服务器错误: 状态码 \(httpResponse.statusCode)")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("收到的响应数据: \(responseString)")
                }
                
                print("发送成功")
                self.postCreated = true
                self.resetState()
                self.onPostCreated?()
            }
        }.resume()
    }
    
    private func resetState() {
        content = ""
        selectedImages = []
        selectedEntities = []
        isAllSelected = false
        errorMessage = nil
    }
}
