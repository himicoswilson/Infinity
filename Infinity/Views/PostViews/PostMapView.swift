import SwiftUI
import MapKit
import Kingfisher

struct PostMapView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PostMapViewModel
    @State private var scrollProxy: ScrollViewProxy?
    
    init(post: PostDTO) {
        _viewModel = StateObject(wrappedValue: PostMapViewModel(post: post))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Map(coordinateRegion: .constant(viewModel.region),
                        annotationItems: viewModel.visiblePosts) { post in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(
                            latitude: post.location[0].latitude,
                            longitude: post.location[0].longitude
                        )) {
                            PhotosMapMarker(
                                isSelected: viewModel.selectedPosts.contains(where: { 
                                    $0.location[0].locationID == post.location[0].locationID
                                }),
                                count: viewModel.visiblePosts.filter { 
                                    $0.location[0].locationID == post.location[0].locationID
                                }.count
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    viewModel.handlePostSelection(post, selectAllAtLocation: true)
                                }
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.6)
                    
                    MapPostListView(
                        viewModel: viewModel,
                        scrollProxy: $scrollProxy,
                        onPostSelect: handlePostSelection
                    )
                    .frame(height: geometry.size.height * 0.4)
                }
            }
            .navigationTitle("PostInMap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.primary)
                }
            }
        }
        .task {
            await viewModel.loadNearbyPosts()
        }
    }
    
    private func handlePostSelection(_ post: PostDTO) {
        withAnimation(.easeInOut) {
            viewModel.handlePostSelection(post, selectAllAtLocation: false)
        }
        withAnimation {
            scrollProxy?.scrollTo(post.id, anchor: .top)
        }
    }
}

// 重命名为 MapPostListView
private struct MapPostListView: View {
    let viewModel: PostMapViewModel
    @Binding var scrollProxy: ScrollViewProxy?
    let onPostSelect: (PostDTO) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8)
            
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.visiblePosts) { post in
                            MapPostListItem(
                                post: post,
                                isSelected: viewModel.selectedPosts.contains(where: { $0.id == post.id })
                            )
                            .id(post.id)
                            .onTapGesture {
                                onPostSelect(post)
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// 重命名列表项组件
private struct MapPostListItem: View {
    let post: PostDTO
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            if let avatarURL = post.userAvatar,
               let url = URL(string: avatarURL) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.nickName ?? post.userName)
                    .font(.headline)
                Text(post.content)
                    .font(.subheadline)
                    .lineLimit(2)
                Text(post.location[0].locationName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(12)
    }
}

// 地图标记组件
struct PhotosMapMarker: View {
    let isSelected: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            // 外圈
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 26, height: 26)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // 内圈
            Circle()
                .fill(isSelected ? Color.white : Color.accentColor)
                .frame(width: 22, height: 22)
            
            // 选中状态的数字指示
            if isSelected {
                Text("\(count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
            
            // 底部三角形
            if isSelected {
                Triangle()
                    .fill(Color.white)
                    .frame(width: 12, height: 6)
                    .offset(y: 15)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
    }
}

// 三角形形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
