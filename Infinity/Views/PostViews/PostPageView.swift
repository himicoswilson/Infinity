import SwiftUI

struct PostPageView: View {
    @ObservedObject private var postViewModel: PostViewModel
    @ObservedObject private var entitiesViewModel: EntitiesViewModel
    @State private var refreshTask: Task<Void, Never>?
    
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
                    EntitiesView(viewModel: entitiesViewModel)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    
                    Divider()
                    
                    if let errorMessage = postViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if postViewModel.posts.isEmpty && !postViewModel.isLoading {
                        Text("没有可用的帖子")
                            .padding()
                    } else {
                        ForEach(postViewModel.posts, id: \.id) { post in
                            PostCardView(postdto: post)
                                .onAppear {
                                    if post.id == postViewModel.posts.last?.id {
                                        postViewModel.fetchPosts()
                                    }
                                }
                        }
                        
                        if postViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            postViewModel.fetchPosts(refresh: true)
            await entitiesViewModel.fetchEntities()
        }
    }
}
