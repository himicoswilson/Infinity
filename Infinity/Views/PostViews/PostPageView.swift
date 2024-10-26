import SwiftUI

struct PostPageView: View {
    @ObservedObject private var postViewModel: PostViewModel
    @ObservedObject private var entitiesViewModel: EntitiesViewModel
    @State private var refreshTask: Task<Void, Never>?
    @State private var scrollOffset: CGFloat = 0
    @State private var showHeader: Bool = true
    @State private var topSafeAreaHeight: CGFloat = 0
    @State private var lastScrollValue: CGFloat = 0
    @State private var lastScrollTime: Date = Date()
    @State private var scrollDirection: ScrollDirection = .none
    @State private var accumulatedScrollDistance: CGFloat = 0
    @State private var scrollThreshold: CGFloat = 50
    @State private var postListViewHeight: CGFloat = 0
    
    init(entitiesViewModel: EntitiesViewModel, postViewModel: PostViewModel) {
        self.entitiesViewModel = entitiesViewModel
        self.postViewModel = postViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                if showHeader {
                    VStack {
                        HStack {
                            Text("Infinity")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 5) // 额外的左侧间距
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        
                        EntitiesView(viewModel: entitiesViewModel, onEntitySelected: onEntitySelected, selectedEntity: postViewModel.selectedEntity)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        
                        Divider()
                            .padding(.top, 8)
                    }
                    .transition(.move(edge: .top))
                }
                
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin.y)
                    }
                    .frame(height: 0)

                    PostListView(
                        postViewModel: postViewModel,
                        onLastPostAppear: fetchMorePosts
                    )
                    .background(
                        GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                self.postListViewHeight = geometry.size.height
                            }
                            return Color.clear
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    let currentTime = Date()
                    let timeDifference = currentTime.timeIntervalSince(lastScrollTime)
                    let scrollDelta = value - lastScrollValue
                    
                    if timeDifference > 0.1 { // 50毫秒
                        accumulatedScrollDistance += scrollDelta
                        
                        let newDirection: ScrollDirection
                        if scrollDelta > 0 {
                            newDirection = .down
                        } else if scrollDelta < 0 {
                            newDirection = .up
                        } else {
                            newDirection = .none
                        }
                        
                        if newDirection != scrollDirection {
                            scrollDirection = newDirection
                            accumulatedScrollDistance = scrollDelta // 重置累积距离
                        }
                        
                        // 使用 PostListView 的实际高度来计算是否接近底部
                        let isNearBottom = -value > (postListViewHeight - UIScreen.main.bounds.height)
                        
                        // 只有当累积滚动距离超过阈值且不在底部附近时才触发头部的显示/隐藏
                        if abs(accumulatedScrollDistance) > scrollThreshold && !isNearBottom {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                // 如果在顶部或接近顶部，始终显示头部
                                if value > -10 {
                                    showHeader = true
                                } else {
                                    showHeader = scrollDirection == .down
                                }
                            }
                            accumulatedScrollDistance = 0 // 重置累积距离
                        }
                        
                        lastScrollTime = currentTime
                        lastScrollValue = value
                    }
                }
                .refreshable {
                    await refreshData()
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80) // CustomTabView 的高度
                }
            }
            .safeAreaInset(edge: .top) {
                if !showHeader {
                    BlurView(style: .regular)
                        .frame(height: topSafeAreaHeight)
                        .frame(maxWidth: .infinity)
                        .offset(y: -topSafeAreaHeight)
                }
            }
            .padding(.bottom, 10)
            .onAppear {
                topSafeAreaHeight = geometry.safeAreaInsets.top
                Task {
                    if entitiesViewModel.entities.isEmpty {
                        await entitiesViewModel.fetchEntities()
                    }
                    await postViewModel.loadInitialEntityPosts(entities: entitiesViewModel.entities)
                    if postViewModel.posts.isEmpty {
                        postViewModel.fetchPosts(refresh: true)
                    }
                }
            }
            .onDisappear {
                refreshTask?.cancel()
            }
            .animation(.easeOut(duration: 0.3), value: showHeader)
        }
    }
    
    func refreshData() async {
        refreshTask?.cancel()
        refreshTask = Task {
            if let entity = postViewModel.selectedEntity {
                postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
            } else {
                postViewModel.fetchPosts(refresh: true)
            }
            await entitiesViewModel.fetchEntities()
        }
    }

    func onEntitySelected(_ entity: EntityDTO?) {
        if let entity = entity {
            if postViewModel.selectedEntity?.entityID == entity.entityID {
                postViewModel.setCurrentEntity(nil)
            } else {
                postViewModel.setCurrentEntity(entity)
                if postViewModel.postsByEntityID[entity.entityID] == nil {
                    Task {
                        postViewModel.fetchPostsByEntity(entityId: entity.entityID, refresh: true)
                    }
                }
            }
        } else {
            postViewModel.setCurrentEntity(nil)
        }
    }

    private func fetchMorePosts() {
        guard !postViewModel.isLoading else { return }

        if postViewModel.isShowingEntityPosts {
            if let entityID = postViewModel.currentEntityID {
                postViewModel.fetchPostsByEntity(entityId: entityID)
            }
        } else {
            postViewModel.fetchPosts()
        }
    }
}

struct PostListView: View {
    @ObservedObject var postViewModel: PostViewModel
    var onLastPostAppear: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 0) {
            let posts = postViewModel.getPostsForCurrentEntity()
            ForEach(posts) { post in
                VStack(spacing: 0) {
                    PostCardView(postdto: post)
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                    
                    if post.id != posts.last?.id {
                        Divider()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, -2)
            }
            
            if postViewModel.hasMorePostsForCurrentView {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .onAppear {
                        onLastPostAppear()
                    }
            } else if !postViewModel.isLoading {
                Text("没有啦，快去记录一条吧～")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

enum ScrollDirection {
    case up, down, none
}
