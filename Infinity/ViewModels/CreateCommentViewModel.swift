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
                    // 检查是否是给自己的帖子评论
                    let currentUsername = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.username)
                    let postAuthor = self.postdto?.userName ?? self.parentComment?.userName
                    
                    // 只有在评论者和帖子作者不同时才发送通知
                    if currentUsername != postAuthor {
                        let notificationBody = self.commentText.isEmpty ? "[评论]" : self.commentText
                        let nickName = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.nickName) ?? "有人"
                        NotificationService.shared.sendBarkNotification(
                            barkToken: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.loverBarkToken) ?? "",
                            title: "\(nickName)回复了你",
                            body: notificationBody,
                            group: Constants.BarkAPI.defaultGroup,
                            icon: Constants.BarkAPI.defaultIcon,
                            scheme: Constants.BarkAPI.defaultScheme
                        )
                    }
                    
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
