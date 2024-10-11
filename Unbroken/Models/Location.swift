import Foundation
import CoreLocation

struct Location: Identifiable, Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let locationName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "LocationID"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case locationName = "LocationName"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}