import Foundation

struct Comment: Identifiable, Codable {
    let id: Int
    let content: String
    let commentDateTime: Date
    let userID: Int
    let postID: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "CommentID"
        case content = "Content"
        case commentDateTime = "CommentDateTime"
        case userID = "UserID"
        case postID = "PostID"
    }
}