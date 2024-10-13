import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 100, endRadius: 470)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    HeartAnimation()
                        .frame(width: 200, height: 200)
                    
                    Text("Welcome Gao")
                        .font(.custom("Zapfino", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 2, x: 0, y: 2)
                    
                    VStack(spacing: 20) {
                        CustomTextField(placeholder: "用户名", text: $username, imageName: "person.fill")
                        CustomTextField(placeholder: "密码", text: $password, imageName: "lock.fill", isSecure: true)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.login(username: username, password: password)
                    }) {
                        Text("登录")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(25)
                            .shadow(color: .purple.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    NavigationLink(destination: RegisterView(viewModel: viewModel)) {
                        Text("还没有账号？注册")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct HeartAnimation: View {
    
    var body: some View {
        SwiftUI.Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.pink)
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var imageName: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            SwiftUI.Image(systemName: imageName)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.pink, lineWidth: 2)
        )
    }
}
