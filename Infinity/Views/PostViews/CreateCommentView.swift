import SwiftUI
import Kingfisher

struct CreateCommentView: View {
    @StateObject private var viewModel: CreateCommentViewModel
    @EnvironmentObject var coupleViewModel: CoupleViewModel
    @FocusState private var focusedField: Bool
    @Binding var showCreateCommentView: Bool
    
    init(postdto: PostDTO? = nil, parentComment: CommentDTO? = nil, showCreateCommentView: Binding<Bool>, onCommentCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreateCommentViewModel(postdto: postdto, parentComment: parentComment, onCommentCreated: onCommentCreated))
        _showCreateCommentView = showCreateCommentView
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let postdto = viewModel.postdto {
                        // 显示帖子内容
                        PostContentView(postdto: postdto)
                    } else if let parentComment = viewModel.parentComment {
                        // 显示父评论内容
                        ParentCommentView(comment: parentComment)
                    }
                    // 评论输入区域
                    CommentInputView(commentText: $viewModel.commentText, coupleViewModel: _coupleViewModel, name: (viewModel.postdto?.nickName ?? viewModel.parentComment?.nickName)!)
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        withAnimation {
                            self.showCreateCommentView = false
                        }
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("回复")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("发布")
                        .foregroundColor(viewModel.commentText.isEmpty || viewModel.isLoading ? .gray : .primary)
                        .onTapGesture {
                            if !viewModel.commentText.isEmpty && !viewModel.isLoading {
                                viewModel.sendComment()
                            }
                        }
                }
            }
            .onAppear {
                focusedField = true
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView("发布中...")
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                    }
                }
            )
            .onChange(of: viewModel.commentCreated) { created in
                if created {
                    self.showCreateCommentView = false
                }
            }
        }
    }
}

struct PostContentView: View {
    let postdto: PostDTO
    
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .cornerRadius(1)
                    .padding(.leading, 24)
                    .frame(height: !postdto.images.isEmpty ? geometry.size.height + 205 : geometry.size.height - 40)
                    .offset(y: 60)
            }
        }
        .padding(.bottom, postdto.images.isEmpty ? 15 : 0)
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
                        }
                    }
                    .padding(.leading, 60)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, -20)
            }
            .padding(.vertical, 5)
        }
    }
}

struct ParentCommentView: View {
    let comment: CommentDTO
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 头像 昵称 内容 时间
            HStack(alignment: .top) {
                ZStack {
                    // 加载的头像图片
                    if let avatarURL = comment.userAvatar, let url = URL(string: avatarURL) {
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
                    Text(comment.nickName ?? comment.userName)
                        .font(.headline)
                        .padding(.top, 2)
                    
                    Text(comment.content)
                        .font(.body)
                        .padding(.trailing, -50)
                }
                
                Spacer()
                Text(Date.formatRelativeTime(from: comment.createdAt))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding(.bottom, 15)

            // 左侧的矩形直线
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .cornerRadius(1)
                    .padding(.leading, 24)
                    .frame(height: geometry.size.height - 50)
                    .offset(y: 55)
            }
        }
    }
}

struct CommentInputView: View {
    @FocusState private var focusedField: Bool
    @Binding var commentText: String
    @EnvironmentObject var coupleViewModel: CoupleViewModel
    var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // 头像
                    KFImage(URL(string: coupleViewModel.currentUser.avatar ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(coupleViewModel.currentUser.nickName ?? coupleViewModel.currentUser.userName)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        TextField("回复 \(name)", text: $commentText, axis: .vertical)
                            .font(.body)
                            .padding(.top, 5)
                            .focused($focusedField)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            focusedField = true
        }
    }
}
