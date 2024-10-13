import SwiftUI
import PhotosUI

struct CreatePostView: View {
    static private let MAX_IMAGE_COUNT = 20
    
    @Binding var showCreatePost: Bool
    @StateObject private var viewModel = CreatePostViewModel()
    @State private var photoList: [PhotosPickerItem] = []
    @FocusState private var focusedField: Bool
    @State private var showCreateEntityView = false
    
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
                    withAnimation {
                        self.showCreatePost = false
                    }
                }
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            
            ScrollView {
                TextField("说点什么吧～", text: $viewModel.content, axis: .vertical)
                    .frame(minHeight: 48)
                    .font(.title3)
                    .padding()
                    .focused($focusedField)
                
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
                }
                .padding()
                
                Divider()
                    .padding()
                
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
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.fetchEntities()
        }
    }
}

struct EntityItemView: View {
    let entity: Entity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            if let avatarURL = entity.avatar, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
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
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 72)
        .onTapGesture(perform: onTap)
    }
}
