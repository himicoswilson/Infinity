import SwiftUI

struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel = PostDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.content)
                    .font(.body)
                
               
                
                Text(post.postDateTime.formattedString())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                ForEach(viewModel.comments) { comment in
                    CommentView(comment: comment)
                }
            }
            .padding()
        }
        .navigationTitle("帖子详情")
        .onAppear {
            viewModel.fetchComments(for: post.id)
        }
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(comment.content)
            Text(comment.commentDateTime.formattedString())
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
