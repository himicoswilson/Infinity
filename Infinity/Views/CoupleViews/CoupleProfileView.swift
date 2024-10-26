import SwiftUI
import Kingfisher
import PhotosUI

struct CoupleProfileView: View {
    @StateObject private var coupleViewModel: CoupleViewModel
    @State private var showImagePicker = false
    @State private var selectedBackgroundImage: UIImage?
    @State private var selectedBackgroundItem: PhotosPickerItem?
    @State private var showConfirmationDialog = false
    @State private var imageHeight: CGFloat = 0
    let headerHeight: CGFloat = 300

    init(coupleViewModel: CoupleViewModel) {
        _coupleViewModel = StateObject(wrappedValue: coupleViewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { imageGeometry in
                        // 背景图片
                        if let couple = coupleViewModel.couple {
                            PhotosPicker(selection: $selectedBackgroundItem, matching: .images) {
                                if let bgImageURL = couple.bgImg {
                                    KFImage(URL(string: bgImageURL))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width, height: max(0, headerHeight + imageGeometry.frame(in: .global).minY))
                                        .clipped()
                                        .offset(y: -imageGeometry.frame(in: .global).minY)
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
                        }
                    }
                    .frame(height: headerHeight)
                    
                    LazyVStack(spacing: 8) {
                        if let couple = coupleViewModel.couple, let _ = coupleViewModel.user1, let _ = coupleViewModel.user2 {
                            VStack(spacing: 0) {
                                HStack(spacing: 20) {
                                    UserInfoView(user: coupleViewModel.currentUser, uploadAvatar: { image in
                                        coupleViewModel.uploadAvatar(image: image, for: coupleViewModel.currentUser)
                                    })
                                    
                                    SwiftUI.Image(systemName: "heart.fill")
                                        .foregroundColor(SwiftUI.Color.red)
                                        .font(SwiftUI.Font.system(size: 40))
                                    
                                    UserInfoView(user: coupleViewModel.lover, uploadAvatar: { image in
                                        coupleViewModel.uploadAvatar(image: image, for: coupleViewModel.lover)
                                    })
                                }
                                .padding()
                                .offset(y: -30)
                                
                                SwiftUI.Text("我们已经在一起 \(timeTogether(since: couple.anniversaryDate))啦")
                                    .font(.headline)
                                    .padding(.top, -30)

                                Divider()
                                    .padding(.top, 20)

                                SwiftUI.Text("小白爱小高！！")
                                    .font(.system(size: 40, weight: .bold))
                                    .padding(.top, 50)
                                
                                Spacer()
                            }
                        } else if let errorMessage = coupleViewModel.errorMessage {
                            SwiftUI.Text(errorMessage)
                                .foregroundColor(SwiftUI.Color.red)
                                .padding(.top, 100)
                        } else {
                            SwiftUI.Text("加载中...")
                                .padding(.top, 100)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .onAppear {
            if coupleViewModel.couple == nil {
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
        guard let image = selectedBackgroundImage else {
            print("没有选择背景图片")
            return
        }
        coupleViewModel.uploadBackgroundImage(image)
    }
}

struct UserInfoView: View {
    let user: User
    let uploadAvatar: (UIImage) -> Void
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
                    if let image = selectedImage {
                        uploadAvatar(image)
                    }
                }
                Button("取消", role: .cancel) {
                    selectedImage = nil
                }
            }
            
            Text(user.nickName ?? user.userName)
                .font(.headline)
        }
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

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
