import Foundation

struct Pet: Identifiable, Codable {
    let id: Int
    var petName: String
    var species: String
    var avatar: String?
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "PetID"
        case petName = "PetName"
        case species = "Species"
        case avatar = "Avatar"
        case userID = "UserID"
    }
}