import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.3)]), center: .center, startRadius: 100, endRadius: 470)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                CoupleAnimation()
                    .frame(width: 200, height: 200)
                
                Text("Start the journey of love")
                    .font(.custom("Zapfino", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .pink, radius: 2, x: 0, y: 2)
                
                VStack(spacing: 20) {
                    CustomTextField(placeholder: "用户名", text: $username, imageName: "person.fill")
                    CustomTextField(placeholder: "密码", text: $password, imageName: "lock.fill", isSecure: true)
                    CustomTextField(placeholder: "邮箱", text: $email, imageName: "envelope.fill")
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.register(username: username, password: password, email: email)
                }) {
                    Text("注册")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(25)
                        .shadow(color: .pink.opacity(0.5), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationBarTitle("注册", displayMode: .inline)
        .preferredColorScheme(colorScheme) // 确保整个视图遵循系统颜色方案
    }
}

struct CoupleAnimation: View {
    
    var body: some View {
        HStack(spacing: 20) {
            SwiftUI.Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.purple)
            
            SwiftUI.Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.pink)
            
            SwiftUI.Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.purple)
        }
    }
}
