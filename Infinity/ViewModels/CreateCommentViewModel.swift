import Foundation

class CreateCommentViewModel: ObservableObject {
    @Published var commentText: String = ""
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var commentCreated: Bool = false
    
    let postdto: PostDTO?
    let parentComment: CommentDTO?
    var onCommentCreated: ((CommentDTO) -> Void)?
    
    init(postdto: PostDTO? = nil, parentComment: CommentDTO? = nil, onCommentCreated: @escaping (CommentDTO) -> Void) {
        self.postdto = postdto
        self.parentComment = parentComment
        self.onCommentCreated = onCommentCreated
    }
    
    func sendComment() {
        guard !commentText.isEmpty else { return }
        
        isLoading = true
        
        var parameters: [String: Any] = [
            "content": commentText,
            "postID": (postdto?.id ?? parentComment?.postID)!
        ]
        
        if let parentComment = parentComment {
            parameters["parentCommentID"] = parentComment.commentID
        }
        
        Task {
            do {
                let newComment: CommentDTO = try await APIService.shared.post(Constants.APIEndpoints.comments, parameters: parameters)
                DispatchQueue.main.async {
                    self.commentText = ""
                    self.isLoading = false
                    self.commentCreated = true
                    self.onCommentCreated?(newComment)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = APIService.handleError(error)
                    self.showAlert = true
                    self.isLoading = false
                }
            }
        }
    }
}
