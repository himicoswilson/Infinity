import SwiftUI

struct PostListView: View {
    @ObservedObject var postViewModel: PostViewModel
    var onLastPostAppear: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 0) {
            let posts = postViewModel.getPostsForCurrentEntity()
            ForEach(posts) { post in
                NavigationLink {
                    PostDetailView(postdto: post)
                } label: {
                    VStack(spacing: 0) {
                        PostCardView(postdto: post)
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                        
                        if post.id != posts.last?.id {
                            Divider()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, -2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if postViewModel.hasMorePostsForCurrentView {
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
}
