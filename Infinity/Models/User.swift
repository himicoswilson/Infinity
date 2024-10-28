import Foundation

struct User: Codable {
    let userID: Int
    let userName: String
    let nickName: String?
    let password: String
    let email: String
    let avatar: String?
    let barkToken: String?
    let registrationDate: String
    let logoutDate: String?
    let updatedAt: String
    let lastLoginTime: String
    let lastActiveTime: String
    let deleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID
        case userName
        case nickName
        case password
        case email
        case avatar
        case barkToken
        case registrationDate
        case logoutDate
        case updatedAt
        case lastLoginTime
        case lastActiveTime
        case deleted
    }
}
