import SwiftUI
import Kingfisher

struct PostCardView: View {
    let postdto: PostDTO
    @State private var selectedImageURL: String?
    @State private var showImagePreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            .padding(.horizontal)
            .padding(.top, 5)
            
            // 图片
            if !postdto.images.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(postdto.images, id: \.id) { image in
                                KFImage(URL(string: image.imageURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 250)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedImageURL = image.imageURL
                                        showImagePreview = true
                                    }
                            }
                        }
                        .padding(.leading, 73)
                        .padding(.trailing, 10)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .sheet(isPresented: $showImagePreview) {
            if let imageURL = selectedImageURL {
                ImagePreviewView(imageURL: imageURL)
            }
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
