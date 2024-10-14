import SwiftUI
import PhotosUI
import Kingfisher

struct CreatePostView: View {
    static private let MAX_IMAGE_COUNT = 20
    
    @Binding var showCreatePost: Bool
    @ObservedObject var entitiesViewModel: EntitiesViewModel
    @StateObject private var viewModel: CreatePostViewModel
    @State private var photoList: [PhotosPickerItem] = []
    @FocusState private var focusedField: Bool
    @State private var showCreateEntityView = false
    @Environment(\.colorScheme) var colorScheme

    init(showCreatePost: Binding<Bool>, entitiesViewModel: EntitiesViewModel, onPostCreated: @escaping () -> Void) {
        _showCreatePost = showCreatePost
        self.entitiesViewModel = entitiesViewModel
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(entities: entitiesViewModel.entities, onPostCreated: onPostCreated))
    }
    
    var body: some View {
        VStack {
            // 添加顶部安全区域间距
            Color.clear
                .frame(height: 10)
            
            // 顶部
            HStack {
                Button("取消") {
                    withAnimation {
                        self.showCreatePost = false
                    }
                }
                Spacer()
                Button("发布") {
                    viewModel.createPost()
                }
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal)
            
            ScrollView {
                TextField("说点什么吧～", text: $viewModel.content, axis: .vertical)
                    .frame(minHeight: 48)
                    .font(.body)
                    .padding()
                    .focused($focusedField)
                
                // 图片选择器和预览
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            SwiftUI.Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Button(action: {
                                        if let index = viewModel.selectedImages.firstIndex(of: image) {
                                            viewModel.removeImage(at: index)
                                        }
                                    }) {
                                        SwiftUI.Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                    .padding(5),
                                    alignment: .topTrailing
                                )
                        }
                        
                        PhotosPicker(selection: $photoList,
                                     maxSelectionCount: CreatePostView.MAX_IMAGE_COUNT - viewModel.selectedImages.count,
                                     matching: .images) {
                            VStack {
                                SwiftUI.Image(systemName: "plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 120, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .onChange(of: photoList) { newValue in
                            Task {
                                do {
                                    var newImages: [UIImage] = []
                                    for item in newValue {
                                        if let data = try await item.loadTransferable(type: Data.self) {
                                            if let uiImage = UIImage(data: data) {
                                                newImages.append(uiImage)
                                            }
                                        }
                                    }
                                    viewModel.addImages(newImages)
                                } catch {
                                    print("Error loading images: \(error)")
                                }
                                photoList.removeAll()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Divider()
                    .padding()
                
                // 实体选择
                VStack {
                    HStack {
                        Text("关联实体")
                            .font(.headline)
                        Spacer()
                        HStack {
                            SwiftUI.Image(systemName: viewModel.isAllSelected ? "checkmark.square.fill" : "square")
                                .renderingMode(.template)
                                .foregroundColor(viewModel.isAllSelected ? .blue : .gray)
                            Text("全选")
                        }
                        .onTapGesture {
                            viewModel.toggleAllSelection()
                        }
                    }
                    .padding(.bottom)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.entities) { entity in
                                EntityItemView(entity: entity, isSelected: viewModel.selectedEntities.contains(entity.id)) {
                                    viewModel.toggleEntitySelection(entity.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, -16)
                }
                .padding(.horizontal)
            }
            .onReceive(entitiesViewModel.$entities) { newEntities in
                viewModel.refreshEntities(newEntities)
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("发布中...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                } else if viewModel.showError {
                    VStack {
                        Text("发布失败")
                            .font(.headline)
                        Text(viewModel.errorMessage ?? "未知错误")
                            .font(.subheadline)
                        Button("重新发送") {
                            viewModel.createPost()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                }
            }
        )
        .onChange(of: viewModel.postCreated) { created in
            if created {
                self.showCreatePost = false
            }
        }
    }
}

struct EntityItemView: View {
    let entity: Entity
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            if let avatarURL = entity.avatar, let url = URL(string: avatarURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            HStack(spacing: 2) {
                SwiftUI.Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(entity.entityName)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
        }
        .frame(width: 72)
        .onTapGesture(perform: onTap)
    }
}
