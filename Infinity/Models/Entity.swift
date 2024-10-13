struct Entity: Identifiable, Codable {
    var id: Int { entityID }
    let entityID: Int
    let entityName: String
    let entityType: String
    let avatar: String?
    let coupleID: Int
}