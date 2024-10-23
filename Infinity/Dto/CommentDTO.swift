struct CommentDTO: Identifiable, Codable {
    var id: Int { commentID }
    let commentID: Int
    let content: String
    let userID: Int
    let userName: String
    let nickName: String?
    let userAvatar: String?
    let postID: Int
    let parentCommentID: Int?
    let createdAt: String
    let updatedAt: String
    let deleted: Bool
}