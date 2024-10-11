import Foundation

struct User: Codable {
    let userID: Int
    let userName: String
    let nickName: String
    let password: String
    let email: String
    let avatar: String?
    let registrationDate: String
    let lastLoginTime: String
    let deleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userID"
        case userName
        case nickName
        case password
        case email
        case avatar
        case registrationDate
        case lastLoginTime
        case deleted
    }
}
