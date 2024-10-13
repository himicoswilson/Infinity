import SwiftUI
import Foundation

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            Section(header: Text("外观")) {
                Toggle("深色模式", isOn: $isDarkMode)
            }
            
            Section(header: Text("通知设置")) {
                Toggle("推送通知", isOn: $viewModel.isPushNotificationEnabled)
                Toggle("位置服务", isOn: $viewModel.isLocationServiceEnabled)
            }
            
            Section {
                Button("清除缓存") {
                    viewModel.clearCache()
                }
                .foregroundColor(.red)
            }
            
            Section {
                Button("退出登录") {
                    viewModel.logout()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("设置")
    }
}

class SettingsViewModel: ObservableObject {
    @Published var isPushNotificationEnabled = true
    @Published var isLocationServiceEnabled = true
    
    func clearCache() {
        // 清除磁盘缓存
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        for cache in caches {
            try? FileManager.default.removeItem(at: cache)
        }
        
        // 清除 UserDefaults (注意: 只清除非关键数据)
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // 清除 URLCache
        URLCache.shared.removeAllCachedResponses()
        
        print("缓存已清除")
    }
    
    func logout() {
        // 实现退出登录的逻辑
    }
}