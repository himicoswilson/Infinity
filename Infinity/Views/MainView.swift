import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var coupleViewModel = CoupleViewModel()
    @StateObject private var entitiesViewModel = EntitiesViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        PostPageView(entitiesViewModel: entitiesViewModel)
                            .tabItem {
                                SwiftUI.Image(systemName: "seal.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .tag(0)

                        BirthdayCardView()
                            .tag(1)
                        
                        CoupleProfileView()
                            .environmentObject(coupleViewModel)
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
                .sheet(isPresented: $showCreatePost) {
                    CreatePostView(showCreatePost: $showCreatePost, entitiesViewModel: entitiesViewModel)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
            if authViewModel.isAuthenticated {
                entitiesViewModel.fetchEntities()
            }
        }
    }
}
