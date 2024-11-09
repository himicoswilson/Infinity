import CoreLocation

class LocationUtils {
    static let shared = LocationUtils()
    private let geocoder = CLGeocoder()
    
    private init() {}
    
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                var components: [String] = []
                
                if let name = placemark.name {
                    components.append(name)
                }
                if let thoroughfare = placemark.thoroughfare {
                    components.append(thoroughfare)
                }
                if let locality = placemark.locality {
                    components.append(locality)
                }
                
                return components.isEmpty ? "未知位置" : components.joined(separator: ", ")
            } else {
                return String(format: "%.6f, %.6f", latitude, longitude)
            }
        } catch {
            print("反向地理编码错误: \(error.localizedDescription)")
            return String(format: "%.6f, %.6f", latitude, longitude)
        }
    }
}