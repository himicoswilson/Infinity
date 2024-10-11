import Foundation

struct Couple: Codable {
    let coupleID: Int
    let userID1: Int
    let userID2: Int
    let anniversaryDate: String
    
    enum CodingKeys: String, CodingKey {
        case coupleID = "coupleID"
        case userID1
        case userID2
        case anniversaryDate
    }
    
    var anniversaryDateAsDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: anniversaryDate)
    }
}