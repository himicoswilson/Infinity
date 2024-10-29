import SwiftUI

struct PostPageView: View {
    @ObservedObject private var postViewModel: PostViewModel
    @ObservedObject private var entitiesViewModel: EntitiesViewModel
    @State private var refreshTask: Task<Void, Never>?
    @State private var topSafeAreaHeight: CGFloat = 0
    
    init(entitiesViewModel: EntitiesViewModel, postViewModel: PostViewModel) {
        self.entitiesViewModel = entitiesViewModel
        self.postViewModel = postViewModel
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        ScrollView {
                            HStack {
                                Text("Infinity")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.leading, 5) // 额外的左侧间距
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            
                            EntitiesView(viewModel: entitiesViewModel, onEntitySelected: onEntitySelected, selectedEntity: postViewModel.selectedEntity)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                            
                            Divider()
                                .padding(.top, 8)
                            
                            PostListView(
                                postViewModel: postViewModel,
                                onLastPostAppear: fetchMorePosts
                            )
                        }
                        .refreshable {
                            await refreshData()
                        }
                    }
                    
                    BlurView(style: .regular)
                        .frame(height: topSafeAreaHeight)
                        .frame(maxWidth: .infinity)
                        .offset(y: -topSafeAreaHeight)
                }
                .onAppear {
                    topSafeAreaHeight = geometry.safeAreaInsets.top
                    Task {
                        if entitiesViewModel.entities.isEmpty {
                            await entitiesViewModel.fetchEntities()
                        }
                        await postViewModel.loadInitialEntityPosts(entities: entitiesViewModel.entities)
                        if postViewModel.posts.isEmpty {
                            postViewModel.fetchPosts(refresh: true)
                        }
                    }
                }
                .onDisappear {
                    refreshTask?.cancel()
                }
            }
        }
    }
    
    func refreshData() async {
        refreshTask?.cancel()
        refreshTask = Task {
            if let entity = postViewModel.selectedEntity {
                postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
            } else {
                postViewModel.fetchPosts(refresh: true)
            }
            await entitiesViewModel.fetchEntities()
        }
    }
    
    func onEntitySelected(_ entity: EntityDTO?) {
        if let entity = entity {
            if postViewModel.selectedEntity?.entityID == entity.entityID {
                postViewModel.setCurrentEntity(nil)
            } else {
                postViewModel.setCurrentEntity(entity)
                if postViewModel.postsByEntityID[entity.entityID] == nil {
                    Task {
                        postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
                    }
                }
            }
        } else {
            postViewModel.setCurrentEntity(nil)
        }
    }
    
    private func fetchMorePosts() {
        guard !postViewModel.isLoading else { return }
        
        if postViewModel.isShowingEntityPosts {
            if let entityID = postViewModel.currentEntityID {
                postViewModel.fetchPostsByEntity(entityId: entityID)
            }
        } else {
            postViewModel.fetchPosts()
        }
    }
}
