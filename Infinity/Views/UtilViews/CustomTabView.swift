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
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            
            BlurView(style: .systemMaterial)
                .frame(height: 80)
                .overlay(
                    HStack(spacing: 0) {
                        ForEach(0..<3) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                VStack {
                                    SwiftUI.Image(systemName: tabIcon(for: index))
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTab == index ? .primary : .secondary)
                                }
                                .offset(y: -10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .overlay(
                        Button(action: showCreatePost) {
                            SwiftUI.Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .frame(width: 56, height: 40)
                                .background(colorScheme == .dark ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .offset(y: -10)
                    )
                )
                .background(colorScheme == .dark ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "seal.fill"
        case 1: return ""
        case 2: return "heart.fill"
        default: return ""
        }
    }
}
