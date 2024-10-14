import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            SwiftUI.Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(40)
        }
    }
}
