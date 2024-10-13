import Foundation

struct Mood: Identifiable, Codable {
    let id: Int
    let moodName: String
    let moodIcon: String
    let creatorID: Int
    let isPublic: Bool
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "MoodID"
        case moodName = "MoodName"
        case moodIcon = "MoodIcon"
        case creatorID = "CreatorID"
        case isPublic = "IsPublic"
        case status = "Status"
    }
}