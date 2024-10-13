import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    let content: String
    let postDateTime: Date
    let userID: Int
    let coupleID: Int
    var locationID: Int?
    let createdAt: Date
    let updatedAt: Date
    let isDeleted: Bool
    
    // 新增字段
    var userName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "postID"
        case content
        case postDateTime
        case userID
        case coupleID
        case locationID
        case createdAt
        case updatedAt
        case isDeleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        userID = try container.decode(Int.self, forKey: .userID)
        coupleID = try container.decode(Int.self, forKey: .coupleID)
        locationID = try container.decodeIfPresent(Int.self, forKey: .locationID)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let postDateTimeString = try container.decodeIfPresent(String.self, forKey: .postDateTime),
           let date = dateFormatter.date(from: postDateTimeString) {
            postDateTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .postDateTime, in: container, debugDescription: "Date string does not match format")
        }
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match format")
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Date string does not match format")
        }
    }
}
