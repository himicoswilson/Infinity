import SwiftUI
import Kingfisher
import PhotosUI

struct CoupleProfileView: View {
    @StateObject private var coupleViewModel: CoupleViewModel
    @State private var showImagePicker = false
    @State private var selectedBackgroundImage: UIImage?
    @State private var selectedBackgroundItem: PhotosPickerItem?
    @State private var showConfirmationDialog = false

    init(coupleViewModel: CoupleViewModel) {
        _coupleViewModel = StateObject(wrappedValue: coupleViewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let couple = coupleViewModel.couple, let _ = coupleViewModel.user1, let _ = coupleViewModel.user2 {
                // 背景图片
                PhotosPicker(selection: $selectedBackgroundItem, matching: .images) {
                    if let bgImageURL = couple.bgImg {
                        BackgroundImageView(imageURL: bgImageURL)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                }
                .frame(maxWidth: .infinity)
                .onChange(of: selectedBackgroundItem) { _ in
                    Task {
                        if let data = try? await selectedBackgroundItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                selectedBackgroundImage = uiImage
                                showConfirmationDialog = true
                            }
                        }
                    }
                }
                .confirmationDialog("上传背景图片?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("确认上传") {
                        uploadBackgroundImage()
                    }
                    Button("取消", role: .cancel) {
                        selectedBackgroundImage = nil
                    }
                }
                
                HStack(spacing: 20) {
                    UserInfoView(user: coupleViewModel.currentUser)
                    
                    SwiftUI.Image(systemName: "heart.fill")
                        .foregroundColor(SwiftUI.Color.red)
                        .font(SwiftUI.Font.system(size: 40))
                    
                    UserInfoView(user: coupleViewModel.lover)
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
            } else if let errorMessage = coupleViewModel.errorMessage {
                SwiftUI.Text(errorMessage)
                    .foregroundColor(SwiftUI.Color.red)
            } else {
                SwiftUI.Text("加载中...")
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if coupleViewModel.couple == nil{
                coupleViewModel.fetchCoupleInfo()
            }
        }
    }
    
    private func timeTogether(since dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: dateString) else {
            return "计算错误"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        
        guard let days = components.day else {
            return "计算错误"
        }
        
        return "\(days) 天"
    }
    
    private func uploadBackgroundImage() {
        guard let image = selectedBackgroundImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let coupleId = coupleViewModel.couple?.coupleID else {
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
                        coupleViewModel.fetchCoupleInfo()  // 刷新数据
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
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showConfirmationDialog = false
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let avatarURL = user.avatar {
                    AvatarImageView(imageURL: avatarURL)
                } else {
                    SwiftUI.Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
            }
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            showConfirmationDialog = true
                        }
                    }
                }
            }
            .confirmationDialog("上传头像?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("确认上传") {
                    uploadAvatar()
                }
                Button("取消", role: .cancel) {
                    selectedImage = nil
                }
            }
            
            Text(user.nickName ?? user.userName)
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

struct BackgroundImageView: View {
    let imageURL: String
    
    var body: some View {
        KFImage(URL(string: imageURL))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 300)
            .clipped()
    }
}

struct AvatarImageView: View {
    let imageURL: String
    
    var body: some View {
        KFImage(URL(string: imageURL))
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 3)
    }
}
