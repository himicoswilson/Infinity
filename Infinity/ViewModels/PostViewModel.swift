import Foundation
import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [PostDTO] = []
    @Published var postsByEntity: [PostDTO] = []
    @Published var isShowingEntityPosts: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var hasMorePosts = true
    
    private var currentPage = 1
    private let postsPerPage = 10
    private var fetchTask: Task<Void, Never>?
    private var allPosts: [PostDTO] = []  // 用于存储所有帖子

    private func resetPagination() {
        currentPage = 1
        hasMorePosts = true
        posts = []
        postsByEntity = []
    }

    func fetchPosts(refresh: Bool = false) {
        fetchTask?.cancel()
        fetchTask = Task {
            if refresh {
                resetPagination()
            }
            
            guard !self.isLoading else { return }
            guard self.hasMorePosts else { return }

            self.isLoading = true
            
            do {
                let endpoint = "\(Constants.APIEndpoints.posts)?page=\(currentPage)&limit=\(postsPerPage)"
                let fetchedPosts: [PostDTO] = try await APIService.shared.fetch(endpoint)
                if Task.isCancelled { return }
                
                let updatedPosts = fetchedPosts.map { post in
                    var updatedPost = post
                    updatedPost.updateRelativeTime()
                    return updatedPost
                }
                
                if refresh {
                    self.posts = updatedPosts
                } else {
                    self.posts.append(contentsOf: updatedPosts)
                }
                
                self.hasMorePosts = fetchedPosts.count == postsPerPage
                self.currentPage += 1
                self.errorMessage = nil
                // 在成功获取帖子后，添加以下代码：
                self.allPosts = self.posts  // 保存所有帖子的副本
            } catch let error as APIError {
                if !Task.isCancelled {
                    handleError(error)
                }
            } catch {
                if !Task.isCancelled {
                    handleUnexpectedError(error)
                }
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
    
    private func handleUnexpectedError(_ error: Error) {
        self.errorMessage = "发生未预期的错误: \(error.localizedDescription)"
        print("获取帖子时发生未预期的错误: \(error)")
    }

    func fetchPostsByEntity(entityId: Int, refresh: Bool = false) {
        fetchTask?.cancel()
        fetchTask = Task {
            if refresh {
                resetPagination()
            }
            
            guard !self.isLoading else { return }
            guard self.hasMorePosts else { return }

            self.isLoading = true

            do {
                let endpoint = Constants.APIEndpoints.postByEntityId(entityId, currentPage, postsPerPage)
                let fetchedPosts: [PostDTO] = try await APIService.shared.fetch(endpoint)
                if Task.isCancelled { return }
                
                let updatedPosts = fetchedPosts.map { post in
                    var updatedPost = post
                    updatedPost.updateRelativeTime()
                    return updatedPost
                }
                
                if refresh {
                    self.postsByEntity = updatedPosts
                } else {
                    self.postsByEntity.append(contentsOf: updatedPosts)
                }
                
                self.hasMorePosts = fetchedPosts.count == postsPerPage
                self.currentPage += 1
                self.errorMessage = nil
            } catch let error as APIError {
                if !Task.isCancelled {
                    handleError(error)
                }
            } catch {
                if !Task.isCancelled {
                    handleUnexpectedError(error)
                }
            }
            self.isLoading = false
        }
    }

    func switchToAllPosts() {
        self.posts = self.allPosts  // 恢复所有帖子
        self.isShowingEntityPosts = false
    }
}

class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func fetchComments(for postID: Int) {
        // 实现获取评论的逻辑
    }
}
