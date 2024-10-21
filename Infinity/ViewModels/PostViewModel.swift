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

    func fetchPosts(refresh: Bool = false) {
        fetchTask?.cancel()
        fetchTask = Task {
            if refresh {
                currentPage = 1
                hasMorePosts = true
                posts = []
            } else if self.isLoading {
                return
            }
            
            guard self.hasMorePosts else { return }

            self.isLoading = true
            do {
                let endpoint = "\(Constants.APIEndpoints.posts)?page=\(currentPage)&limit=\(postsPerPage)"
                let fetchedPosts: [PostDTO] = try await APIService.shared.get(endpoint)
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
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = APIService.handleError(error)
                }
            }
            
            if !Task.isCancelled {
                self.isLoading = false
            }
        }
    }

    func fetchPostsByEntity(entityId: Int, refresh: Bool = false) {
        fetchTask?.cancel()
        fetchTask = Task {
            if refresh {
                currentPage = 1
                hasMorePosts = true
                postsByEntity = []
            } else if self.isLoading {
                return
            }
            
            guard self.hasMorePosts else { return }

            self.isLoading = true

            do {
                let endpoint = Constants.APIEndpoints.postByEntityId(entityId, currentPage, postsPerPage)
                let fetchedPosts: [PostDTO] = try await APIService.shared.get(endpoint)
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
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = APIService.handleError(error)
                }
            }
            
            if !Task.isCancelled {
                self.isLoading = false
            }
        }
    }
}

class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func fetchComments(for postID: Int) {
        // 实现获取评论的逻辑
    }
}
