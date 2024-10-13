import SwiftUI
import Kingfisher

struct CoupleProfileView: View {
    @StateObject private var viewModel = CoupleViewModel()
    @State private var showImagePicker = false
    @State private var selectedBackgroundImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            if let couple = viewModel.couple, let user1 = viewModel.user1, let user2 = viewModel.user2 {
                // 背景图片
                Button(action: {
                    showImagePicker = true
                }) {
                    if let bgImageURL = couple.bgImg {
                        KFImage(URL(string: bgImageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedBackgroundImage, completion: uploadBackgroundImage)
                }
                
                HStack(spacing: 20) {
                    UserInfoView(user: user1)
                    
                    SwiftUI.Image(systemName: "heart.fill")
                        .foregroundColor(SwiftUI.Color.red)
                        .font(SwiftUI.Font.system(size: 40))
                    
                    UserInfoView(user: user2)
                }
                .padding()
                .offset(y: -30)
                
                SwiftUI.Text("我们已经在一起 \(timeTogether(since: couple.anniversaryDate))啦")
                    .font(.headline)
                    .padding(.top, -30)

                // 分割线
                Divider()
                    .padding(.top, 20)

                SwiftUI.Text("小白爱小高！！")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 50)
                
                Spacer() // 将内容推到顶部
            } else if let errorMessage = viewModel.errorMessage {
                SwiftUI.Text(errorMessage)
                    .foregroundColor(SwiftUI.Color.red)
            } else {
                SwiftUI.Text("加载中...")
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            viewModel.fetchCoupleInfo()
        }
    }
    
    private func timeTogether(since dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: dateString) else {
            return "计算错误"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: startDate, to: Date())
        
        var result = ""
        if let years = components.year, years > 0 {
            result += "\(years) 年 "
        }
        if let months = components.month, months > 0 {
            result += "\(months) 个月 "
        }
        if let days = components.day, days > 0 {
            result += "\(days) 天"
        }
        
        return result.isEmpty ? "不到一天" : result
    }
    
    private func uploadBackgroundImage() {
        guard let image = selectedBackgroundImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let coupleId = viewModel.couple?.coupleID else {
            print("无法获取图片数据或 coupleId")
            return
        }
        
        let url = URL(string: Constants.APIEndpoints.uploadCoupleBackground(coupleId))!
        
        print("请求URL: \(url.absoluteString)") // 打印URL以进行调试
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("无法获取token")
            return
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"background\"; filename=\"background.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("上传背景图片错误: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("服务器响应状态码: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("背景图片上传成功")
                    DispatchQueue.main.async {
                        viewModel.fetchCoupleInfo()  // 刷新数据
                    }
                } else {
                    print("背景图片上传失败")
                }
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("服务器响应内容: \(responseString)")
            }
        }.resume()
    }
}

struct UserInfoView: View {
    let user: User
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Button(action: {
                print("头像按钮被点击")
                showImagePicker = true
            }) {
                if let avatarURL = user.avatar {
                    KFImage(URL(string: avatarURL))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 3)
                } else {
                    SwiftUI.Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, completion: uploadAvatar)
            }
            
            SwiftUI.Text(user.nickName)
                .font(.headline)
        }
    }
    
    private func uploadAvatar() {
        print("uploadAvatar 函数被调用")
        guard let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("无法获取图片数据")
            return
        }
        
        print("准备上传图片，大小：\(imageData.count) 字节")
        
        let url = URL(string: Constants.APIEndpoints.uploadUserAvatar(user.userID))!
        print("网络请求URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // 添加token到请求头
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("无法获取token")
            return
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("开始网络请求")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("上传头像错误: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("服务器响应状态码: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("头像上传成功")
                    // 这里可以添加更新本地头像URL的逻辑
                } else {
                    print("头像上传失败")
                }
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("服务器响应内容: \(responseString)")
            }
        }.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var completion: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        print("创建 UIImagePickerController")
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("图片选择完成")
            if let image = info[.originalImage] as? UIImage {
                print("成功获取选中的图片")
                parent.image = image
                parent.completion()
            } else {
                print("无法获取选中的图片")
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("图片选择被取消")
            picker.dismiss(animated: true)
        }
    }
}
