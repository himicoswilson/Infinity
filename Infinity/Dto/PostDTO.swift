import SwiftUI
import Foundation

struct PostDTO: Identifiable, Codable {
    var id: Int { postID }
    let postID: Int
    let content: String
    let userID: Int
    let userName: String
    let nickName: String?
    let userAvatar: String?
    let coupleID: Int
    let locationID: Int?
    let createdAt: String
    let updatedAt: String
    let images: [ImageDTO]
    let tags: [TagDTO]
    let entities: [EntityDTO]
    let comments: [CommentDTO]
    let deleted: Bool
    
    var relativeTime: String?

    var hasContent: Bool {
        return !content.isEmpty
    }
    
    mutating func updateRelativeTime() {
        self.relativeTime = DateHelper.timeAgo(from: createdAt)
    }
}

// 新增 DateHelper 结构体
struct DateHelper {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 假设日期是 UTC 时间
        return formatter
    }()
    
    static func timeAgo(from dateString: String) -> String {
        guard let date = dateFormatter.date(from: dateString) else {
            return "未知时间"
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)年前"
        } else if let month = components.month, month > 0 {
            return "\(month)个月前"
        } else if let day = components.day, day > 0 {
            return "\(day)天前"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)小时前"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)分钟前"
        } else {
            return "刚刚"
        }
    }
}
