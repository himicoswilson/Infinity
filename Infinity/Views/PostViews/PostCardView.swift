import SwiftUI
import Kingfisher

struct PostCardView: View {
    let postdto: PostDTO
    @State private var showImagePreview = false
    @State private var previewCurrentPage = 0
    @State private var showCreateCommentView = false
    @EnvironmentObject var refreshManager: RefreshManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading){
                // 头像 昵称 内容 时间
                HStack(alignment: .top) {
                    ZStack {
                        // 加载的头像图片
                        if let avatarURL = postdto.userAvatar, let url = URL(string: avatarURL) {
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
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(postdto.nickName ?? postdto.userName)
                            .font(.headline)
                            .padding(.top, 2)
                        
                        if postdto.hasContent {
                            Text(postdto.content)
                                .font(.body)
                                .padding(.trailing, -50)
                        }
                    }
                    
                    Spacer()
                    
                    Text(postdto.relativeTime ?? "未知时间")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                .padding(.top, 5)

                // 左侧的矩形直线
                GeometryReader { geometry in
                    if !postdto.comments.isEmpty {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2)
                            .cornerRadius(1)
                            .padding(.leading, 24)
                            .frame(height: !postdto.images.isEmpty ? geometry.size.height + 241 : geometry.size.height - 15)
                            .offset(y: 60)
                    }
                }
            }
            // 图片和按钮控件
            if !postdto.images.isEmpty {                 
                VStack(alignment: .leading, spacing: 10) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
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
                        .padding(.leading, 60)
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                }
                .padding(.vertical, 5)
            }

            // 评论按钮
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showCreateCommentView = true
            }) {
                HStack {
                    SwiftUI.Image(systemName: "bubble.right")
                        .font(.system(size: 12))
                    Text("评论")
                        .font(.footnote)
                }
                .foregroundColor(.gray)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            .padding(.leading, 60)
            .padding(.vertical, 5)
            .padding(.top, postdto.images.isEmpty ? 5 : 0)
            
            // 评论区
            if !postdto.comments.isEmpty {
                PostCommentView(postdto: postdto, comments: postdto.comments)
            }
        }
        .fullScreenCover(isPresented: $showImagePreview) {
            PhotoPreviewView(images: postdto.images, currentPage: $previewCurrentPage)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showCreateCommentView) {
            CreateCommentView(postdto: postdto, showCreateCommentView: $showCreateCommentView, onCommentCreated: {
                refreshManager.refresh()
            })
        }
    }
}

struct LocationAndTagsView: View {
    var location: String?
    var tags: [TagDTO]  // 假设 TagDTO 结构体包含了 tagName 属性

    var body: some View {
        HStack(spacing: 10) {
            // Location
            if let location = location {
                Text(location)
                    .font(.subheadline)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            }

            // Tags
            ForEach(tags, id: \.id) { tag in
                Text(tag.tagName)
                    .font(.subheadline)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
    }
}

struct PostCommentView: View {
    let postdto: PostDTO
    var comments: [CommentDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let latestComment = findLatestTopLevelComment() {
                VStack(spacing: 0) {
                    CommentItemView(postdto: postdto, comment: latestComment, allComments: comments)
                    
                    let replies = comments.filter { $0.parentCommentID == latestComment.commentID }
                    if let oldestReply = replies.last {
                        // 左侧的矩形直线
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 2)
                                    .cornerRadius(1)
                                    .padding(.leading, 24)
                                    .frame(height: geometry.size.height + 32)
                                    .offset(y: -26)
                            }
                        }
                        
                        CommentItemView(postdto: postdto, comment: oldestReply, allComments: comments)
                    }
                }
            }
        }
    }
    private func findLatestTopLevelComment() -> CommentDTO? {
        for i in (0..<comments.count).reversed() {
            if comments[i].parentCommentID == nil {
                return comments[i]
            }
        }
        return nil
    }
}

struct CommentItemView: View {
    let postdto: PostDTO
    let comment: CommentDTO
    let allComments: [CommentDTO]
    @State private var isLongPressed = false
    @State private var showReplyView = false
    @EnvironmentObject var refreshManager: RefreshManager

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top, spacing: 0) {
                // 头像
                KFImage(URL(string: comment.userAvatar ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(comment.nickName ?? comment.userName)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text(Date.formatRelativeTime(from: comment.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, -8)
                    }
                    Text(comment.content)
                        .font(.body)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            
            // 回复按钮
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showReplyView = true
            }) {
                HStack {
                    SwiftUI.Image(systemName: "arrowshape.turn.up.left")
                        .font(.system(size: 12))
                    Text("回复")
                        .font(.footnote)
                }
                .foregroundColor(.gray)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            .padding(.leading, 60)
        }
        .padding(.top, 10)
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    isLongPressed = true
                    UIPasteboard.general.string = comment.content
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
        )
        .alert(isPresented: $isLongPressed) {
            Alert(title: Text("评论已复制"), dismissButton: .default(Text("确定")))
        }
        .sheet(isPresented: $showReplyView) {
            CreateCommentView(parentComment: comment, showCreateCommentView: $showReplyView, onCommentCreated: {
                refreshManager.refresh()
            })
        }
    }
}
