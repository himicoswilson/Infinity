import Foundation
import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [PostDTO] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var hasMorePosts = true
    
    private var currentPage = 1
    private let postsPerPage = 10

    func fetchPosts(refresh: Bool = false) {
        guard !isLoading else { return }
        if refresh {
            currentPage = 1
            posts = []
            hasMorePosts = true
        }
        guard hasMorePosts else { return }
        
        isLoading = true
        
        Task {
            do {
                let endpoint = "\(Constants.APIEndpoints.posts)?page=\(currentPage)&limit=\(postsPerPage)"
                let fetchedPosts: [PostDTO] = try await APIService.shared.fetch(endpoint)
                if refresh {
                    self.posts = fetchedPosts
                } else {
                    self.posts.append(contentsOf: fetchedPosts)
                }
                self.currentPage += 1
                self.hasMorePosts = fetchedPosts.count == postsPerPage
                self.errorMessage = nil
            } catch let error as APIError {
                handleError(error)
            }
            self.isLoading = false
        }
    }

    private func handleError(_ error: APIError) {
        switch error {
        case .invalidURL:
            self.errorMessage = "无效的URL"
        case .noData:
            self.errorMessage = "服务器没有返回数据"
        case .decodingError:
            self.errorMessage = "数据解码失败"
        case .encodingError:
            self.errorMessage = "数据编码失败"
        case .networkError(let underlyingError):
            self.errorMessage = "网络错误: \(underlyingError.localizedDescription)"
        case .httpError(let statusCode):
            self.errorMessage = "HTTP错误: 状态码 \(statusCode)"
        }
        print("获取帖子错误: \(self.errorMessage ?? "未知错误")")
    }
}

class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func fetchComments(for postID: Int) {
        // 实现获取评论的逻辑
    }
}
