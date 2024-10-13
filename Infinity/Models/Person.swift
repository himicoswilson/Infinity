import Foundation

struct Person: Identifiable, Codable {
    let id: Int
    var personName: String
    var type: String
    var avatar: String?
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "PersonID"
        case personName = "PersonName"
        case type = "Type"
        case avatar = "Avatar"
        case userID = "UserID"
    }
}