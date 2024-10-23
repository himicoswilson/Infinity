import SwiftUI
import Kingfisher

struct CreateCommentView: View {
    @StateObject private var viewModel: CreateCommentViewModel
    @EnvironmentObject var coupleViewModel: CoupleViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: Bool
    @Binding var showCreateCommentView: Bool
    
    init(postdto: PostDTO, showCreateCommentView: Binding<Bool>, onCommentCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreateCommentViewModel(postdto: postdto, onCommentCreated: onCommentCreated))
        _showCreateCommentView = showCreateCommentView
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        // 头像 昵称 内容 时间
                        HStack(alignment: .top) {
                            ZStack {
                                // 加载的头像图片
                                if let avatarURL = viewModel.postdto.userAvatar, let url = URL(string: avatarURL) {
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
                                Text(viewModel.postdto.nickName ?? viewModel.postdto.userName)
                                    .font(.headline)
                                    .padding(.top, 2)
                                
                                if viewModel.postdto.hasContent {
                                    Text(viewModel.postdto.content)
                                        .font(.body)
                                        .padding(.trailing, -50)
                                }
                            }
                            
                            Spacer()
                            Text(viewModel.postdto.relativeTime ?? "未知时间")
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
                                .frame(height: geometry.size.height + 205)
                                .offset(y: 60)
                        }
                    }
                    // 图片
                    if !viewModel.postdto.images.isEmpty {                 
                        VStack(alignment: .leading, spacing: 10) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(viewModel.postdto.images.indices, id: \.self) { index in
                                        KFImage(URL(string: viewModel.postdto.images[index].imageURL))
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

                    // 发送评论
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
                                    TextField("回复 \(viewModel.postdto.nickName ?? viewModel.postdto.userName)", text: $viewModel.commentText, axis: .vertical)
                                        .font(.body)
                                        .padding(.top, 5)
                                        .focused($focusedField)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 10)
                        }
                    }
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
                    Button("发布") {
                        viewModel.sendComment()
                    }
                    .foregroundColor(.primary)
                    .disabled(viewModel.commentText.isEmpty || viewModel.isLoading)
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
