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
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    EntitiesView(viewModel: entitiesViewModel, onEntitySelected: onEntitySelected)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    
                    Divider()
                    
                    if let errorMessage = postViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if (postViewModel.isShowingEntityPosts ? postViewModel.postsByEntity : postViewModel.posts).isEmpty && !postViewModel.isLoading {
                        Text("没有可用的帖子")
                            .padding()
                    } else {
                        VStack(spacing: 25) {
                            ForEach(postViewModel.isShowingEntityPosts ? postViewModel.postsByEntity : postViewModel.posts, id: \.id) { post in
                                PostCardView(postdto: post)
                                    .onAppear {
                                        if post.id == (postViewModel.isShowingEntityPosts ? postViewModel.postsByEntity : postViewModel.posts).last?.id {
                                            if postViewModel.isShowingEntityPosts {
                                                postViewModel.fetchPostsByEntity(entityId: selectedEntity!.entityID)
                                            } else {
                                                postViewModel.fetchPosts()
                                            }
                                        }
                                    }
                            }
                            
                            if postViewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            
                            if !postViewModel.isLoading && !postViewModel.posts.isEmpty {
                                Text("没有啦，快去记录一条吧～")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
        }
        .padding(.bottom, 10)
        .onAppear{
            Task{
                if postViewModel.posts.isEmpty {
                    postViewModel.fetchPosts()
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
                postViewModel.switchToAllPosts()
            } else {
                // 选择新的实体
                selectedEntity = entity
                postViewModel.isShowingEntityPosts = true
                postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
            }
        } else {
            // 取消选择实体
            selectedEntity = nil
            postViewModel.switchToAllPosts()
        }
    }
}
