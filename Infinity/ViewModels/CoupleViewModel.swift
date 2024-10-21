import SwiftUI
import Foundation

@MainActor
class CoupleViewModel: ObservableObject {
    @Published var couple: Couple?
    @Published var user1: User?
    @Published var user2: User?
    @Published var errorMessage: String?
    
    func fetchCoupleInfo() {
        Task {
            do {
                let userID = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
                let fetchedCouple: Couple = try await APIService.shared.get(Constants.APIEndpoints.coupleInfo + "\(userID)")
                self.couple = fetchedCouple
                
                self.user1 = try await APIService.shared.get(Constants.APIEndpoints.users + "/\(fetchedCouple.userID1)")
                self.user2 = try await APIService.shared.get(Constants.APIEndpoints.users + "/\(fetchedCouple.userID2)")
                
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("获取信息错误: \(self.errorMessage ?? "未知错误")")
            }
        }
    }
    
    func uploadBackgroundImage(_ image: UIImage) {
        Task {
            guard let imageData = image.jpegData(compressionQuality: 0.8),
                let coupleId = couple?.coupleID else {
                    print("无法获取图片数据或 coupleId")
                    return
            }
            
            let url = Constants.APIEndpoints.uploadCoupleBackground(coupleId)
            
            do {
                let _: EmptyResponse = try await APIService.shared.upload(
                    url,
                    method: .put,
                    files: ["background": imageData],
                    fileNames: ["background": "background.jpg"],
                    mimeTypes: ["background": "image/jpeg"],
                    fileFieldName: "background"
                )
                print("背景图片上传成功")
                DispatchQueue.main.async {
                    self.fetchCoupleInfo()
                }
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("背景图片上传失败: \(self.errorMessage ?? "未知错误")")
            }
        }
    }
    
    func uploadAvatar(image: UIImage, for user: User) {
        Task {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("无法获取图片数据")
                return
            }
            
            let url = Constants.APIEndpoints.uploadUserAvatar(user.userID)
            
            do {
                let _: EmptyResponse = try await APIService.shared.upload(
                    url,
                    method: .put,
                    files: ["avatar": imageData],
                    fileNames: ["avatar": "avatar.jpg"],
                    mimeTypes: ["avatar": "image/jpeg"],
                    fileFieldName: "avatar"
                )
                print("头像上传成功")
                DispatchQueue.main.async {
                    self.fetchCoupleInfo()
                }
            } catch {
                self.errorMessage = APIService.handleError(error)
                print("头像上传失败: \(self.errorMessage ?? "未知错误")")
            }
        }
    }

    var currentUser: User {
        let currentUserId = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
        guard currentUserId != 0 else {
            fatalError("当前用户ID不存在")
        }
        return currentUserId == user1?.userID ? user1! : user2!
    }

    var lover: User {
        let currentUserId = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userID)
        guard currentUserId != 0 else {
            fatalError("当前用户ID不存在")
        }
        return currentUserId == user1?.userID ? user2! : user1!
    }
}
