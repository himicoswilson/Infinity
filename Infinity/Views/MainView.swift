import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var coupleViewModel = CoupleViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        PostPageView()
                            .tabItem {
                                SwiftUI.Image(systemName: "seal.fill")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .tag(0)

                        BirthdayCardView()
                            .tag(1)
                        
                        CoupleProfileView()
                            .environmentObject(coupleViewModel)
                            .tabItem {
                                SwiftUI.Image(systemName: "heart")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .tag(2)
                    }
                    .tint(.black)

                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                    showCreatePost = true
                                }) {
                                    SwiftUI.Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 40)
                                        .background(Color.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }
                }
                .sheet(isPresented: $showCreatePost) {
                    CreatePostView(showCreatePost: $showCreatePost)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}
