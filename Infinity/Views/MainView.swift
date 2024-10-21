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
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                PostPageView(entitiesViewModel: entitiesViewModel, postViewModel: postViewModel)
                    .tabItem {
                        SwiftUI.Image(systemName: "seal.fill")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .tag(0)

                BirthdayCardView()
                    .tag(1)
                
                CoupleProfileView(coupleViewModel: coupleViewModel)
                    .tabItem {
                        SwiftUI.Image(systemName: "heart")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .tag(2)
            }
            .accentColor(colorScheme == .dark ? .white : .black)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showCreatePost = true
                    }) {
                        SwiftUI.Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(width: 56, height: 40)
                            .background(colorScheme == .dark ? Color.white : Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Spacer()
                }
                .padding(.bottom, 8)
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
