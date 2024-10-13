import SwiftUI

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
    
    mutating func updateRelativeTime() {
        self.relativeTime = timeAgo(from: createdAt)
    }
}

func timeAgo(from dateString: String) -> String {
    print("开始计算时间")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
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
        return "\(day)天"
    } else if let hour = components.hour, hour > 0 {
        return "\(hour)小时前"
    } else if let minute = components.minute, minute > 0 {
        return "\(minute)分钟前"
    } else {
        return "刚刚"
    }
}
