struct ImageDTO: Identifiable, Codable {
    var id: Int { imageID }
    let imageID: Int
    let imageURL: String
    let postID: Int
}