import SwiftUI

class CommentsManager: ObservableObject {
    @Published var comments: [CommentDTO] = []
    
    func addComment(_ comment: CommentDTO) {
        comments.insert(comment, at: 0)
        print("评论列表: \(comments)")
        print("评论: \(comment)")
    }
}