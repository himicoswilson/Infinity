struct TagDTO: Identifiable, Codable {
    var id: Int { tagID }
    let tagID: Int
    let tagName: String
    let creatorID: Int
}