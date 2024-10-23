import Foundation

class CreateCommentViewModel: ObservableObject {
    @Published var commentText: String = ""
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var commentCreated: Bool = false
    
    let postdto: PostDTO
    let parentCommentID: String?
    var onCommentCreated: (() -> Void)?
    
    init(postdto: PostDTO, parentCommentID: String? = nil, onCommentCreated: @escaping () -> Void) {
        self.postdto = postdto
        self.parentCommentID = parentCommentID
        self.onCommentCreated = onCommentCreated
    }
    
    func sendComment() {
        guard !commentText.isEmpty else { return }
        
        isLoading = true
        
        var parameters: [String: Any] = [
            "content": commentText,
            "postID": postdto.id
        ]
        
        if let parentCommentID = parentCommentID {
            parameters["parentCommentID"] = parentCommentID
        }
        
        Task {
            do {
                let _: CommentDTO = try await APIService.shared.post(Constants.APIEndpoints.comments, parameters: parameters)
                DispatchQueue.main.async {
                    self.commentText = ""
                    self.isLoading = false
                    self.commentCreated = true
                    self.onCommentCreated?()
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
