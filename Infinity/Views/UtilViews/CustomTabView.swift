import SwiftUI

struct CustomTabView<Content: View>: View {
    @Binding var selectedTab: Int
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    var showCreatePost: () -> Void
    
    init(selectedTab: Binding<Int>, showCreatePost: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
        self.showCreatePost = showCreatePost

        // 隐藏tabbar的背景
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                content
            }
            .accentColor(colorScheme == .dark ? .white : .black)
            
            customTabBar
                .background(
                    AdaptiveBlurView()
                        .edgesIgnoringSafeArea(.bottom)
                )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(imageName: "seal.fill", tab: 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            createPostButton
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            tabButton(imageName: "heart.fill", tab: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 78)
    }
    
    private func tabButton(imageName: String, tab: Int) -> some View {
        Button(action: { selectedTab = tab }) {
            SwiftUI.Image(systemName: imageName)
                .font(.system(size: 22))
                .foregroundColor(selectedTab == tab ? (colorScheme == .dark ? .white : .black) : .gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .offset(y: -8)
        }
    }
    
    private var createPostButton: some View {
        Button(action: showCreatePost) {
            SwiftUI.Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .frame(width: 56, height: 40)
                .background(colorScheme == .dark ? Color.white : Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .offset(y: -8)
        }
    }
}
