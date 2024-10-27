import Foundation
import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [PostDTO] = []
    @Published var postsByEntityID: [Int: [PostDTO]] = [:]
    @Published var isShowingEntityPosts: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var currentEntityID: Int?
    @Published var selectedEntity: EntityDTO?
    @Published var hasMorePostsByEntityID: [Int: Bool] = [:]
    private var currentPageByEntityID: [Int: Int] = [:]
    private var hasMorePostsForMainPage: Bool = true
    private var currentPageForMainPage: Int = 1
    private var postsPerPage: Int = 10

    private var fetchTask: Task<Void, Never>?
    private var loadInitialTask: Task<Void, Never>?

    func fetchPosts(refresh: Bool = false) {
        fetchTask?.cancel()
        fetchTask = Task {
            if refresh {
                currentPageForMainPage = 1
                hasMorePostsForMainPage = true
                posts = []
            } else if self.isLoading {
                return
            }
            
            guard hasMorePostsForMainPage else { return }

            self.isLoading = true
            do {
                let endpoint = "\(Constants.APIEndpoints.posts)?page=\(currentPageForMainPage)&limit=\(postsPerPage)"
                let fetchedPosts: [PostDTO] = try await APIService.shared.get(endpoint)
                if Task.isCancelled { return }
                
                let updatedPosts = fetchedPosts.map { post in
                    let updatedPost = post
                    return updatedPost
                }
                
                if refresh {
                    self.posts = updatedPosts
                } else {
                    self.posts.append(contentsOf: updatedPosts)
                }
                
                hasMorePostsForMainPage = fetchedPosts.count == postsPerPage
                currentPageForMainPage += 1
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
        Task {
            if refresh {
                currentPageByEntityID[entityId] = 1
                hasMorePostsByEntityID[entityId] = true
                postsByEntityID[entityId] = []
            } else if self.isLoading {
                return
            }
            
            guard hasMorePostsByEntityID[entityId] ?? true else { return }

            self.isLoading = true

            do {
                let currentPage = currentPageByEntityID[entityId] ?? 1
                let endpoint = Constants.APIEndpoints.postByEntityId(entityId, currentPage, postsPerPage)
                let fetchedPosts: [PostDTO] = try await APIService.shared.get(endpoint)
                if Task.isCancelled { return }
                
                let updatedPosts = fetchedPosts.map { post in
                    let updatedPost = post
                    return updatedPost
                }

                if refresh {
                    self.postsByEntityID[entityId] = updatedPosts
                } else {
                    self.postsByEntityID[entityId, default: []].append(contentsOf: updatedPosts)
                }
                
                hasMorePostsByEntityID[entityId] = fetchedPosts.count == postsPerPage
                currentPageByEntityID[entityId] = (currentPageByEntityID[entityId] ?? 1) + 1
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

    func loadInitialEntityPosts(entities: [EntityDTO]) async {
        loadInitialTask?.cancel()
        loadInitialTask = Task {
            for entity in entities {
                if postsByEntityID[entity.entityID] == nil {
                    fetchPostsByEntity(entityId: entity.entityID, refresh: true)
                }
                if Task.isCancelled { break }
            }
        }
        await loadInitialTask?.value
    }

    func getPostsForCurrentEntity() -> [PostDTO] {
        guard let currentEntityID = currentEntityID else {
            return posts
        }
        return postsByEntityID[currentEntityID] ?? []
    }

    func setCurrentEntity(_ entity: EntityDTO?) {
        selectedEntity = entity
        currentEntityID = entity?.entityID
        isShowingEntityPosts = entity != nil
    }

    var hasMorePostsForCurrentView: Bool {
        if isShowingEntityPosts {
            return hasMorePostsByEntityID[currentEntityID ?? -1] ?? false
        } else {
            return hasMorePostsForMainPage
        }
    }
}

class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    func fetchComments(for postID: Int) {
        // 实现获取评论的逻辑
    }
}
