import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var coupleViewModel = CoupleViewModel()
    @StateObject private var postViewModel = PostViewModel()
    @StateObject private var entitiesViewModel = EntitiesViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false
    @State private var isLoading = true
    @Environment(\.colorScheme) var colorScheme
    @State private var opacity = 0.0
    @StateObject private var refreshManager = RefreshManager()

    var body: some View {
        Group {
            if isLoading {
                SplashView()
                    .opacity(1 - opacity)
            } else if authViewModel.isAuthenticated {
                mainContent
            } else {
                LoginView(viewModel: authViewModel)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 0.5), value: opacity)
            }
        }
        .onAppear {
            checkAuthAndLoadData()
        }
        .onChange(of: authViewModel.loginSuccessful) { success in
            if success {
                isLoading = true
                checkAuthAndLoadData()
            }
        }
        .environmentObject(refreshManager)
        .onChange(of: refreshManager.shouldRefresh) { _ in
            Task {
                await loadInitialData()
            }
        }
    }

    private var mainContent: some View {
        CustomTabView(selectedTab: $selectedTab, showCreatePost: {
            showCreatePost = true
        }) {
            ZStack {
                switch selectedTab {
                case 0:
                    PostPageView(entitiesViewModel: entitiesViewModel, postViewModel: postViewModel)
                        .environmentObject(coupleViewModel)
                case 1:
                    BirthdayCardView()
                case 2:
                    CoupleProfileView(coupleViewModel: coupleViewModel)
                default:
                    EmptyView()
                }
            }
        }
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.5), value: opacity)
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(showCreatePost: $showCreatePost, entitiesViewModel: entitiesViewModel, onPostCreated: refreshMainView)
        }
    }

    private func checkAuthAndLoadData() {
        authViewModel.checkAuthenticationStatus()
        if authViewModel.isAuthenticated {
            Task {
                await loadInitialData()
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 1.0
                    isLoading = false
                }
            }
            coupleViewModel.fetchCoupleInfo()
        } else {
            withAnimation(.easeInOut(duration: 0.5)) {
                opacity = 1.0
                isLoading = false
            }
        }
    }

    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            print("加载初始数据")
            group.addTask { await entitiesViewModel.fetchEntities() }
            group.addTask { await postViewModel.fetchPosts(refresh: true) }
        }
    }

    func refreshMainView() {
        Task {
            await loadInitialData()
        }
    }
}
