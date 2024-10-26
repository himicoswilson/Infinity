import Foundation

extension Date {
    static func formatRelativeTime(from dateString: String) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        // 首先尝试解析完整格式（包含毫秒）
        if let date = dateFormatter.date(from: dateString) {
            return calculateRelativeTime(from: date)
        }
        
        // 如果失败，则尝试解析不包含毫秒的格式
        let truncatedDateString = String(dateString.prefix(19)) // 只取前19个字符
        if let date = dateFormatter.date(from: truncatedDateString) {
            return calculateRelativeTime(from: date)
        }
        
        print("无法解析日期: \(dateString)")
        return "未知时间"
    }
    
    private static func calculateRelativeTime(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
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
        } else if let second = components.second, second > 0 {
            return "\(second)秒前"
        } else {
            return "刚刚"
        }
    }
}
