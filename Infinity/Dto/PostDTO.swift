import SwiftUI
import Foundation

struct PostDTO: Identifiable, Codable {
    var id: Int { postID }
    let postID: Int
    let content: String
    let userID: Int
    let userName: String
    let nickName: String?
    let userAvatar: String?
    let coupleID: Int
    let locationID: Int?
    let createdAt: String
    let updatedAt: String
    let location: [LocationDTO]
    let images: [ImageDTO]
    let tags: [TagDTO]
    let entities: [EntityDTO]
    let comments: [CommentDTO]
    let deleted: Bool

    var hasContent: Bool {
        return !content.isEmpty
    }
}