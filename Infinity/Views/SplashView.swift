import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            SwiftUI.Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(40)
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
}
