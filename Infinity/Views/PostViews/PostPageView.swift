import SwiftUI

struct PostPageView: View {
    @StateObject private var viewModel = PostViewModel()
    @StateObject private var entitiesViewModel: EntitiesViewModel
    
    init(entitiesViewModel: EntitiesViewModel) {
        _entitiesViewModel = StateObject(wrappedValue: entitiesViewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title Section
            Text("Infinity")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    // 人物和宠物页面
                    EntitiesView(viewModel: entitiesViewModel)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    
                    // Divider
                    Divider()
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.posts.isEmpty && !viewModel.isLoading {
                        Text("没有可用的帖子")
                            .padding()
                    } else {
                        ForEach(viewModel.posts, id: \.id) { post in
                            PostCardView(postdto: post)
                                .onAppear {
                                    if post.id == viewModel.posts.last?.id {
                                        viewModel.fetchPosts()
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
            }
            .refreshable {
                refreshData()
            }
        }
        .padding(.bottom, 10)
        .onAppear {
            if viewModel.posts.isEmpty {
                viewModel.fetchPosts()
            }
            if entitiesViewModel.entities.isEmpty  {
                entitiesViewModel.fetchEntities()
            }
        }
    }
    
    func refreshData() {
        viewModel.fetchPosts(refresh: true)
        entitiesViewModel.fetchEntities()
    }
}
