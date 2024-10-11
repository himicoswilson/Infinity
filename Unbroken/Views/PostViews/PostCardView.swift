import SwiftUI

struct PostCardView: View {
    let postdto: PostDTO
    @State private var selectedImageURL: String?
    @State private var showImagePreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 头像 昵称 内容 时间
            HStack(alignment: .top) {
                if let avatarURL = postdto.userAvatar, let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        // 占位符，如果图像尚未加载
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                } else {
                    // 如果没有头像URL，显示灰色的圆形占位符
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(postdto.nickName)
                        .font(.headline)
                        .padding(.top, 2)
                    
                    Text(postdto.content)
                        .font(.body)
                        .padding(.trailing, -50)
                }
                
                Spacer()
                
                Text(timeAgo(from: postdto.createdAt))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            // 图片
            VStack(alignment: .leading, spacing: 10) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(postdto.images, id: \.id) { image in
                            AsyncImage(url: URL(string: image.imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 200, height: 250)
                                        .cornerRadius(10)
                                case .success(let uiImage):
                                    uiImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 250)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedImageURL = image.imageURL
                                            showImagePreview = true
                                        }
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 200, height: 250)
                                        .cornerRadius(10)
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 200, height: 250)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.leading, 73)
                    .padding(.trailing, 10)
                }
            }
            .padding(.vertical, 5)

            // Location and Tags Section
            if postdto.locationID != nil || !postdto.tags.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LocationAndTagsView(location: postdto.locationID == nil ? nil : "Location \(postdto.locationID!)", tags: postdto.tags)
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

func timeAgo(from dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 8*3600)
    
    guard let date = dateFormatter.date(from: dateString) else {
        return "未知时间"
    }
    
    let now = Date()
    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
    
    if let year = components.year, year > 0 {
        return "\(year)年前"
    } else if let month = components.month, month > 0 {
        return "\(month)个月前"
    } else if let day = components.day, day > 0 {
        return "\(day)天前"
    } else if let hour = components.hour, hour > 0 {
        return "\(hour)小时前"
    } else if let minute = components.minute, minute > 0 {
        return "\(minute)分钟前"
    } else {
        return "刚刚"
    }
}
