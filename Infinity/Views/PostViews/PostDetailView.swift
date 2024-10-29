import SwiftUI
import Kingfisher

struct PostDetailView: View {
    let postdto: PostDTO
    @StateObject private var commentsManager: CommentsManager
    @State private var showCreateCommentView = false
    @State private var showImagePreview = false
    @State private var previewCurrentPage = 0
    
    init(postdto: PostDTO) {
        self.postdto = postdto
        _commentsManager = StateObject(wrappedValue: CommentsManager())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 用户信息区
                HStack(alignment: .top, spacing: 12) {
                    // 头像
                    if let avatarURL = postdto.userAvatar, 
                       let url = URL(string: avatarURL) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(postdto.nickName ?? postdto.userName)
                            .font(.headline)
                        
                        Text(Date.formatRelativeTime(from: postdto.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                
                // 帖子内容
                if postdto.hasContent {
                    Text(postdto.content)
                        .font(.body)
                        .padding(.horizontal, 20)
                }
                
                // 图片区域
                if !postdto.images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(postdto.images.indices, id: \.self) { index in
                                KFImage(URL(string: postdto.images[index].imageURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 250)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        previewCurrentPage = index
                                        showImagePreview = true
                                    }
                            }
                        }
                        .padding(.leading, 8)
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -5)
                }
                
                Divider()
                
                // 评论区
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("评论")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showCreateCommentView = true
                        }) {
                            SwiftUI.Image(systemName: "bubble.right")
                        }
                    }
                    
                    // 修改评论显示逻辑
                    ForEach(commentsManager.comments.filter { $0.parentCommentID == nil }) { parentComment in
                        VStack(alignment: .leading, spacing: 0) {
                            // 显示父评论
                            CommentItemView(postdto: postdto, comment: parentComment)
                            
                            // 显示子评论
                            let replies = commentsManager.comments.filter { $0.parentCommentID == parentComment.commentID }
                            if !replies.isEmpty {
                                ForEach(replies) { reply in
                                    CommentItemView(postdto: postdto, comment: reply)
                                }
                            }
                            
                            // 如果不是最后一个父评论，就显示分割线
                            if parentComment.id != commentsManager.comments.filter({ $0.parentCommentID == nil }).last?.id {
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, -20)
                                    .padding(.top, 20)
                            }
                        }
                    }

                    // 最后就显示提示
                    Text("没有更多评论了")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(commentsManager)
        .sheet(isPresented: $showCreateCommentView) {
            CreateCommentView(
                postdto: postdto,
                showCreateCommentView: $showCreateCommentView,
                onCommentCreated: commentsManager.addComment
            )
        }
        .onAppear {
            commentsManager.comments = postdto.comments
        }
        .fullScreenCover(isPresented: $showImagePreview) {
            PhotoPreviewView(images: postdto.images, currentPage: $previewCurrentPage)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
