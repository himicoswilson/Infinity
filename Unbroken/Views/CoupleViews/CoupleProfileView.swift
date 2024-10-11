import SwiftUI
import Kingfisher

struct CoupleProfileView: View {
    @StateObject private var viewModel = CoupleViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if let couple = viewModel.couple, let user1 = viewModel.user1, let user2 = viewModel.user2 {
                // 背景渐变
                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.bottom, -20) // 调整以确保圆角不会露出白色背景
                
                HStack(spacing: 20) {
                    UserInfoView(user: user1)
                    
                    SwiftUI.Image(systemName: "heart.fill")
                        .foregroundColor(SwiftUI.Color.red)
                        .font(SwiftUI.Font.system(size: 40))
                    
                    UserInfoView(user: user2)
                }
                .padding()
                .offset(y: -30) // 使头像部分覆盖背景
                
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
}

struct UserInfoView: View {
    let user: User
    
    var body: some View {
        VStack {
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
            
            SwiftUI.Text(user.nickName)
                .font(.headline)
        }
    }
}
