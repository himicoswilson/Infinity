import SwiftUI
import Kingfisher

struct PostCardView: View {
    let postdto: PostDTO
    @StateObject private var commentsManager: CommentsManager
    @State private var showImagePreview = false
    @State private var previewCurrentPage = 0
    @State private var showCreateCommentView = false
    @State private var showLocationMap = false
    
    init(postdto: PostDTO) {
        self.postdto = postdto
        _commentsManager = StateObject(wrappedValue: CommentsManager())
    }
    
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
                    
                    Text(Date.formatRelativeTime(from: postdto.createdAt))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                .padding(.top, 5)

                // 左侧的矩形直线
                if !commentsManager.comments.isEmpty {
                    GeometryReader { geometry in
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
            // 图片
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
            HStack(spacing: 10) {
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
                
                // 位置按钮
                if !postdto.location.isEmpty {
                    Button(action: {
                        showLocationMap = true
                    }) {
                        HStack {
                            SwiftUI.Image(systemName: "map")
                                .font(.system(size: 12))
                            Text(postdto.location[0].locationName)
                                .font(.footnote)
                        }
                        .foregroundColor(.gray)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                }
            }
            .padding(.leading, 60)
            .padding(.vertical, 5)
            .padding(.top, postdto.images.isEmpty ? 5 : 0)
            
            // 评论区
            if !commentsManager.comments.isEmpty {
                PostCommentView(postdto: postdto, comments: commentsManager.comments)
            }
        }
        .fullScreenCover(isPresented: $showImagePreview) {
            PhotoPreviewView(images: postdto.images, currentPage: $previewCurrentPage)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showCreateCommentView) {
            CreateCommentView(postdto: postdto, showCreateCommentView: $showCreateCommentView, onCommentCreated: commentsManager.addComment)
        }
        // .sheet(isPresented: $showLocationMap) {
        //     let location = Location(
        //         id: postdto.location[0].id,
        //         latitude: postdto.location[0].latitude,
        //         longitude: postdto.location[0].longitude,
        //         locationName: postdto.location[0].locationName
        //     )
        //     MapView(selectedLocation: .constant(location))
        // }
        .environmentObject(commentsManager)
        .onAppear {
            commentsManager.comments = postdto.comments
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
    let comments: [CommentDTO]
    @EnvironmentObject var commentsManager: CommentsManager
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let latestComment = findLatestTopLevelComment() {
                VStack(spacing: 0) {
                    CommentItemView(postdto: postdto, comment: latestComment)
                    
                    let replies = comments.filter { $0.parentCommentID == latestComment.commentID }
                    if let oldestReply = replies.last {
                        CommentItemView(postdto: postdto, comment: oldestReply)
                    }
                }
            }
        }
    }

    private func findLatestTopLevelComment() -> CommentDTO? {
        for comment in comments.reversed() {
            if comment.parentCommentID == nil {
                return comment
            }
        }
        return nil
    }
}

struct CommentItemView: View {
    let postdto: PostDTO
    let comment: CommentDTO
    @State private var showReplyView = false
    @EnvironmentObject var commentsManager: CommentsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topLeading){
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

                if comment.parentCommentID == nil && hasReplies {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 2)
                                .cornerRadius(1)
                                .padding(.leading, 24)
                                .frame(height: geometry.size.height - 19)
                                .offset(y: 55)
                        }
                    }
                }
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
        .sheet(isPresented: $showReplyView) {
            CreateCommentView(parentComment: comment, showCreateCommentView: $showReplyView, onCommentCreated: commentsManager.addComment)
        }
    }

    private var hasReplies: Bool {
        commentsManager.comments.contains { $0.parentCommentID == comment.commentID }
    }
}
