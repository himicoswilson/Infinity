import SwiftUI

struct PostPageView: View {
    @ObservedObject private var postViewModel: PostViewModel
    @ObservedObject private var entitiesViewModel: EntitiesViewModel
    @State private var refreshTask: Task<Void, Never>?
    @State private var selectedEntity: EntityDTO?
    
    init(entitiesViewModel: EntitiesViewModel, postViewModel: PostViewModel) {
        self.entitiesViewModel = entitiesViewModel
        self.postViewModel = postViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Infinity")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 5)

            EntitiesView(viewModel: entitiesViewModel, onEntitySelected: onEntitySelected)
            .padding(.horizontal)
            .padding(.vertical, 5)
        
            Divider()
            
            PostListView(
                postViewModel: postViewModel,
                selectedEntity: $selectedEntity,
                onLastPostAppear: fetchMorePosts
            )
        }
        .refreshable {
            await refreshData()
        }
        .padding(.bottom, 10)
        .onAppear{
            Task{
                if postViewModel.posts.isEmpty {
                    postViewModel.fetchPosts(refresh: true)
                }
                if entitiesViewModel.entities.isEmpty{
                    await entitiesViewModel.fetchEntities()
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
        }
    }
    
    func refreshData() async {
        refreshTask?.cancel()
        refreshTask = Task {
            if let entity = selectedEntity {
                postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
            } else {
                postViewModel.fetchPosts(refresh: true)
            }
            await entitiesViewModel.fetchEntities()
        }
    }

    func onEntitySelected(_ entity: EntityDTO?) {
        if let entity = entity {
            if selectedEntity?.entityID == entity.entityID {
                // 如果再次点击相同的实体，切换回显示所有帖子
                selectedEntity = nil
                postViewModel.isShowingEntityPosts = false
            } else {
                // 选择新的实体
                selectedEntity = entity
                postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
                postViewModel.isShowingEntityPosts = true
            }
        } else {
            // 取消选择实体
            selectedEntity = nil
            postViewModel.isShowingEntityPosts = false
        }
    }

    private func fetchMorePosts() {
        guard !postViewModel.isLoading else { return }
        if !postViewModel.isLoading && postViewModel.hasMorePosts {
            if postViewModel.isShowingEntityPosts {
                postViewModel.fetchPostsByEntity(entityId: selectedEntity!.entityID)
            } else {
                postViewModel.fetchPosts()
            }
        }
    }
}

struct PostListView: View {
    @ObservedObject var postViewModel: PostViewModel
    @Binding var selectedEntity: EntityDTO?
    var onLastPostAppear: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(postViewModel.isShowingEntityPosts ? postViewModel.postsByEntity : postViewModel.posts) { post in
                    VStack(spacing: 0) {
                        PostCardView(postdto: post)
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                        
                        if post.id != (postViewModel.isShowingEntityPosts ? postViewModel.postsByEntity.last?.id : postViewModel.posts.last?.id) {
                            Divider()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, -2)
                }
                
                if postViewModel.hasMorePosts {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .onAppear {
                            onLastPostAppear()
                        }
                } else if !postViewModel.isLoading {
                    Text("没有啦，快去记录一条吧～")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding(.top, -8)
    }
}
