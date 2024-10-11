import Foundation

struct Tag: Identifiable, Codable {
    let id: Int
    let tagName: String
    let creatorID: Int
    let isPublic: Bool
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "TagID"
        case tagName = "TagName"
        case creatorID = "CreatorID"
        case isPublic = "IsPublic"
        case status = "Status"
    }
}