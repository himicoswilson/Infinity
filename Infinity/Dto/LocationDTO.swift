struct LocationDTO: Identifiable, Codable {
    var id: Int { locationID }
    let locationID: Int
    let locationName: String
    let latitude: Double
    let longitude: Double
}