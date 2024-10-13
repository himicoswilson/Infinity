import Foundation

struct Image: Identifiable, Codable {
    let id: Int
    let imageURL: String
    let postID: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "ImageID"
        case imageURL = "ImageURL"
        case postID = "PostID"
    }
}

extension Image {
    // 如果需要，可以在这里添加一些便利方法
    
    // 例如，获取图片的文件名
    var fileName: String {
        URL(string: imageURL)?.lastPathComponent ?? ""
    }
    
    // 或者检查图片URL是否有效
    var isValidURL: Bool {
        URL(string: imageURL) != nil
    }
}